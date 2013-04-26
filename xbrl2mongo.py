#!/usr/bin/env python -S
# -*- coding: utf-8 -*-
from __future__ import with_statement
from pymongo import Connection
from datetime import date
from datetime import timedelta
from time import strftime

import sys
import re
import os
import zipfile
import json
import xml.sax
import io        # for 2.6
import StringIO  # for 3.0


#
# ** If your python is 2.x and xml-cording is utf-8 set follows.
#
reload(sys)
sys.setdefaultencoding('utf-8')


class XMLtoJSON_ContentHandler(xml.sax.handler.ContentHandler):

    def __init__(self, output=sys.stdout, pretty_print=True, indent=2):
        self.output = output
        self.indent = indent
        self.indent_space = ' '*self.indent
        self.pretty_print = pretty_print

        self.last_called = "__init__"

    def startDocument(self):
        self.data = {}
        self.p_data = [ self.data ]
        self.continuations = []
        self.push_text_node = []

        self.last_called = "startDocument"

    def endDocument(self):
        self.print_json()

    def characters(self, content):
        this_push_text_node = self.push_text_node[-1]
        line = re.match('^\s*(.*)$', content)
        if line and len(line.groups()[0]) > 0:
            this_push_text_node(line.groups()[0], self.last_called == "characters")
            self.last_called = "characters"

    def startElement(self, name, attr):
        this_p_data = self.p_data[-1]
        this_data = { 'd': {} }

        def this_push_text_node(node, continued_p):

            node = node.rstrip('\t\n')
            node = node.replace('\t' ,' ' )
            node = node.replace('\\' ,'JPY' )

            data = this_data['d']
            if not data.get('#text'):
                data['#text'] = node
            elif isinstance( (data['#text']) , list):
                if continued_p:
                    data['#text'][-1] = data['#text'][-1] + '\\n' + node
                else:
                    data['#text'].append(node)
            else:
                if continued_p:
                    data['#text'] = data['#text'] + '\\n' +  node
                else:
                    data['#text'] = [data['#text'], node]

        self.push_text_node.append(this_push_text_node)

        for key in attr.getNames():
            value = attr.getValue(key)
            this_data['d'][key] = value

        def cont():
            keys = this_data['d'].keys()

            if keys == ['#text']:
                if not isinstance( (this_data['d']['#text']) , list) :
                    this_data['d'] = this_data['d']['#text']

            if keys:
                if not this_p_data.get(name):
                    this_p_data[name] = this_data['d']
                elif isinstance( (this_p_data[name]) , list) :
                    this_p_data[name].append(this_data['d'])
                else:
                    this_p_data[name] = [this_p_data[name], this_data['d']]

        self.continuations.append(cont)
        self.p_data.append(this_data['d'])

        self.last_called = "startElement"

    def endElement(self, name):
        self.p_data.pop()
        self.push_text_node.pop()
        cont = self.continuations.pop()
        cont()
        self.last_called = "endElement"

    def print_json(self):
        first_time = [1]
        def it (h, nesting=0):
            if isinstance(h, dict):
                if self.pretty_print:
                    if not first_time[0]:
                        self.output.write ( "\n" )
                    else:
                        first_time[0] = 0

                    for i in range(nesting):
                        self.output.write (self.indent_space)

                self.output.write ( "{" )
                l, i = len(h), 0
                for k, v in h.iteritems():
                    self.output.write ( '"' + k + '"' + ':' )
                    it(v, nesting+1)
                    if i < (l-1):
                        self.output.write ( "," )
                        if self.pretty_print:
                            self.output.write ( "\n " )
                            for j in range(nesting):
                                self.output.write (self.indent_space)
                    i+=1
                self.output.write( "}" )

            if isinstance(h, list):
                self.output.write ( "[" )
                l, i = len(h), 0
                for a in h:
                    it(a, nesting+1)
                    if i < (l-1):
                        self.output.write(',')
                    i+=1
                self.output.write ( "]" )

            if isinstance (h, basestring):
                h = h.replace('"', '\\"')
                self.output.write ('"' + h + '"')

        it(self.data)

        if self.pretty_print:
            self.output.write("\n")


class XMLtoJSON():

    def __init__( self, output=None, input=None, input_string=None, indent=2, output_file_append=False ):

        self.indent       = indent

        pretty_print = (self.indent != False) and (self.indent > -1);
        self.handler = XMLtoJSON_ContentHandler( None,
                                                 pretty_print,
                                                 self.indent or 0 )
        self.output_file_append = output_file_append
        self.set_output(output)

        if input != None: # input is given priority.
            self.set_input(input)
        else:
            self.set_input_string(input_string or "")

    def set_output(self, output=None):
        if output == None:
            self.output_type  = "s" # string
        elif isinstance(output, (file, StringIO.StringIO, io.StringIO)):
            self.output_type  = "i" # io_stream
            self.handler.output = output
        elif isinstance(output, (str, basestring)):
            self.output_type  = "f" # file
        else:
            raise TypeError("The specified 'output' type is not surported.")

        self.output           = output

    def set_input(self, input):

        if isinstance(input, file):
            self.input_type = "i" # io_stream
        elif isinstance(input, (str, basestring)):
            self.input_type = "f" # file
        elif isinstance(input, (StringIO.StringIO, io.StringIO)):
            self.set_input_string(input.getvalue())
            return
        else:
            raise TypeError("The specified 'input' type is not surported.")

        self.input        = input

    def set_input_string(self, input_string):
        if isinstance(input_string, (str, basestring)):
            self.input_type = "s" # string
        else:
            raise TypeError("The specified value is not a string.")

        self.input_string = input_string

    def parse_base(self, parsing):

        if self.output_type == "s": #string
            o = StringIO.StringIO()
            self.handler.output = o
            parsing()
            try:
                c = o.getvalue()
            finally:
                o.close()
            return c

        if self.output_type == "f":
            if self.output_file_append:
                mode = 'a'
            else:
                mode = 'w'

            with file(self.output, mode) as f:
                self.handler.output = f
                parsing()

            return

        parsing()

    def parse_string(self, string = None):
        # argument is given the priority.
        def parsing():
            xml.sax.parseString((string or self.input_string), self.handler)

        return self.parse_base(parsing)

    def parse_stream(self, stream = None):
        # argument is given the priority.
        def parsing():
            xml.sax.parse((stream or self.input), self.handler)

        return self.parse_base(parsing)

    def parse_file(self, path = None):
        # argument is given the priority.
        def parsing():
            with file((path or self.input), 'r') as f:
                xml.sax.parse(f, self.handler)

        return self.parse_base(parsing)

    def parse(self):
        if(self.input_type == "s"): # string
            return self.parse_string()
        if(self.input_type == "i"): # io_stream
            return self.parse_stream()
        if(self.input_type == "f"): # file
            return self.parse_file()
        else:
            raise StandardError("input_type is unknown type. -> '"+self.input_type+"' .")


# class XMLtoJSON( output=None, input=None, input_string=None, indent=2, output_file_append=False );
#
# 'output' controls the direction of JSON output.
# 'input' controls the direction of XML input.

# when 'output' is not given, the result will be returned by parse functions as string.
# otherwise, it is an io_stream object, the result will be written in the stream.
# and it is an string object, the result will be written in the file specified path of the string.

# indent controls indent depth of result. default is 2.
# if set false, this will not do pretty printing.

# Example

# p = XMLtoJSON( output=sys.stdout, input="./test.xml", indent=False )
# p.parse()
# This means that. Parse "./test.xml" and print result to sys.stdout with no indent.

#if __name__ == "__main__":
#    p = XMLtoJSON( output="c:\\tdnet-qnedjpsm-85190-20121026024938.json" , input="c:\\tdnet-qnedjpsm-85190-20121026024938.xbrl", indent=True )
#    p.parse()

# "string" -> parse -> "./test.json"

# p = XMLtoJSON( input_string="<?xml version='1.0' encoding='UTF-8'?><abc version='0.1'></abc>" )
# print p.parse()
# => {"abc":
#      {"version":"0.1"}}

# p = XMLtoJSON( output="./test.json", output_file_append=True )
# st = StringIO.StringIO()
# st.write("<?xml version='1.0' encoding='UTF-8'?><abc version='0.1'><bcd>a</bcd>") # this value will be parsed.
# p.set_input(st)
# st.write("<bcd>b</bcd></abc>") # this operation is not meaningful when st is stringIO.
# p.parse() # -> ERROR (SAXParseException)!!!

# when you set 'input' to StringIO.StringIO io.StringIO
# The value that will be parsed is just the value that have already written by the time when set_input() called.

DIRECTORY = "d:\\tsddata\\"


if __name__ == "__main__":

    d = date(2013, 1, 1)
#    d = date.today() - timedelta(days=1)
    strdate = d.strftime("%Y%m%d")

    con = Connection('localhost', 27017)
    db = con.finance
    col = db.finance

    while(True):
        strdirectory = DIRECTORY + strdate + '\\'
        if os.path.exists(strdirectory ) == True:
            filelist = os.listdir(strdirectory)
            for filename in filelist:

#                try:
                zf = zipfile.ZipFile( strdirectory + filename, "r")

                xmllist = zf.namelist()
                for xmlfile in xmllist:
                    if xmlfile.endswith("xbrl") == True :
                        data = zf.read(xmlfile)
                        try:
                            p = XMLtoJSON(  input_string=data, indent=True )
                            data = p.parse()
                            data = data.lstrip("{\"xbrli:xbrl\":\n")
                            data = data.replace("}}\n","}\n")
                            value = json.loads(data)
                            db.finance.insert(value)
                        except:
                            print data
                            print filename + ':' + xmlfile +  ':Error'
                            raise
#                except:
#                    print "zipFile readError : " + filename
#                    raise

                zf.close()
            print strdate + " done."
            d = d +  timedelta(days=1)
            strdate = d.strftime("%Y%m%d")
        else:
            break


    con.disconnect()

    print 'Data Insert End'


