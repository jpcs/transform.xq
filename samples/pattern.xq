xquery version "3.0";

(:
 : Copyright (c) 2011 John Snelson
 :
 : Licensed under the Apache License, Version 2.0 (the "License");
 : you may not use this file except in compliance with the License.
 : You may obtain a copy of the License at
 :
 :     http://www.apache.org/licenses/LICENSE-2.0
 :
 : Unless required by applicable law or agreed to in writing, software
 : distributed under the License is distributed on an "AS IS" BASIS,
 : WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 : See the License for the specific language governing permissions and
 : limitations under the License.
 :)

import module namespace tfm = "http://snelson.org.uk/functions/transform" at "../transform.xq";

let $pattern := "/*:lala//element(foo)/@*"
let $xml := document { <lala><a><foo blah="jim"/><?bar yeah?></a></lala> }
let $node := $xml/lala/a/foo/@blah
let $pred := tfm:pattern($pattern)
return <html xmlns="http://www.w3.org/1999/xhtml">
  <p>{ $pattern }</p>
  <p>{ $pred($node) }</p>
</html>
