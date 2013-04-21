WarmPotato
==========

Simple HTTP server with multi-host facilities and atomic updates.

CAUTION: This project is still in the toy/alpha phase. It is not intended for
high-performance web sites, and probably will not scale well. But I do mean
eventually for WarmPotato to be able to scale as far as a single computer can
go (haven't considered scaling out at this stage).

Concept
=======

The server is completely updated on SIGHUP, and not before. During the update
process, requests continue to be responded to using the previous configuration;
once the update is completely finished, the new config is atomically switched
in. Everything uses a mapping called 'config', which originates from
warmpotato.conf (or other file as specified on the command line).

Compared to a typical Apache + PHP web server, this guarantees that you can't
half-update a web site (for instance, somepage.php includes common.php and
you make a parallel change to both - it's possible, while you're copying the
files over, to have the old somepage read the new common or vice versa).

License
=======

Made available under the MIT license.

Copyright (c) 2011-2013, Chris Angelico

Permission is hereby granted, free of charge, to any person obtaining a copy of 
this software and associated documentation files (the "Software"), to deal in 
the Software without restriction, including without limitation the rights to 
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
of the Software, and to permit persons to whom the Software is furnished to do 
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all 
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
SOFTWARE.
