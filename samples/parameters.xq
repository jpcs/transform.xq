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

let $extended-identity-transform := tfm:mode((
  (: Set up the extended identity transform default rules :)
  tfm:rule("element()",
    function($mode as function(node()*,function() as item()*?) as item()*, $node, $params)
    {
      $mode($node/node()[1],$params),
      $mode($node/following-sibling::node()[1],$params)
    }),
  tfm:rule("text()",
    function($mode as function(node()*,function() as item()*?) as item()*, $node, $params)
    {
      $node,
      $mode($node/following-sibling::node()[1],$params)
    }),
  tfm:rule("attribute()",
    function($mode as function(node()*,function() as item()*?) as item()*, $node, $params)
    {
      text { $node }
    })
))
let $mode := tfm:extend-mode($extended-identity-transform, (
  (: Override the extended identity transform :)
  tfm:rule("@*",
    function($mode, $node)
    {
      ()
    }),
  tfm:rule("para",
    function($mode as function(node()*,function() as item()*?) as item()*, $node, $params)
    {
      <p xmlns="http://www.w3.org/1999/xhtml">{
        $mode($node/@*,$params),
        $mode($node/node()[1],$params)
      }</p>,
      $mode($node/following-sibling::node()[1],$params)
    }),
  tfm:rule("section/title",
    function($mode as function(node()*,function() as item()*?) as item()*, $node, $params)
    {
      <h2 xmlns="http://www.w3.org/1999/xhtml">{
        $mode($node/@*,$params),
        tfm:get-param($params,"number") || ". ",
        $mode($node/node()[1],$params)
      }</h2>,
      $mode($node/following-sibling::node()[1],$params)
    }),
  tfm:rule("article/title",
    function($mode as function(node()*,function() as item()*?) as item()*, $node, $params)
    {
      <h1 xmlns="http://www.w3.org/1999/xhtml">{
        $mode($node/@*,$params),
        $mode($node/node()[1],$params)
      }</h1>,
      $mode($node/following-sibling::node()[1],$params)
    }),
  tfm:rule("section",
    function($mode as function(node()*,function() as item()*?) as item()*, $node, $params)
    {
      <div xmlns="http://www.w3.org/1999/xhtml">{
        $mode($node/@*,$params),
        $mode($node/node()[1],$params)
      }</div>,
      let $number := tfm:get-param($params,"number")
      let $params := tfm:param($params,"number",$number + 1)
      return
        $mode($node/following-sibling::node()[1],$params)
    }),
  tfm:rule("article",
    function($mode as function(node()*,function() as item()*?) as item()*, $node, $params)
    {
      <html xmlns="http://www.w3.org/1999/xhtml">
        <head><title>{ tfm:get-param($params,"title") }</title></head>
        <body>{
          $mode($node/@*,$params),
          $mode($node/node()[1],$params)
        }</body>
      </html>,
      $mode($node/following-sibling::node()[1],$params)
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
  tfm:param("title","Fairy Stories") ! tfm:param(.,"number",1)
)
