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

let $mode := tfm:mode((
  tfm:rule("@*", function($mode, $node)
  {
    ()
  }),
  tfm:rule("para", function($mode, $node)
  {
    <p xmlns="http://www.w3.org/1999/xhtml">{ $mode($node/(@*|node())) }</p>
  }),
  tfm:rule("section/title", function($mode, $node)
  {
    <h2 xmlns="http://www.w3.org/1999/xhtml">{ $mode($node/(@*|node())) }</h2>
  }),
  tfm:rule("article/title", function($mode, $node)
  {
    <h1 xmlns="http://www.w3.org/1999/xhtml">{ $mode($node/(@*|node())) }</h1>
  }),
  tfm:rule("section", function($mode, $node)
  {
    <div xmlns="http://www.w3.org/1999/xhtml">{ $mode($node/(@*|node())) }</div>
  }),
  tfm:rule("article", function($mode, $node)
  {
    <html xmlns="http://www.w3.org/1999/xhtml">
      <head><title>{ $node/*:title/string() }</title></head>
      <body>{ $mode($node/(@*|node())) }</body>
    </html>
  })
))
return $mode(
  <article>
    <title>Lala</title>
    <section id="one" fred="hello">
      <title>One</title>
      <para>Once upon a <link ref="two">time</link></para>
    </section>
    <section id="two">
      <title>Two</title>
      <para>There lived...</para>
    </section>
  </article>,
  ()
)
