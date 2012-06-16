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

Licensed under the BSD Open Source license.

Copyright (c) 2012, Chris Angelico
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list
of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this
list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
