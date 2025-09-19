import React from "react";
import { Button, Card } from "antd";

const UtilsModule = () => {
  const handlePrint = () => {
    // window.print(`<h1>Heading Example</h1>
    // <p style="color:red">This is a paragraph.</p>
    // <blockquote>This is a quote.</blockquote>
    // <img alt="Sample Image" style="width:100px;height:100px" src"https://pic.rmb.bdstatic.com/bjh/bb839a9094c/241114/83649790e78b8e2628ff726e6f176ea7.jpeg?for=bg" />
    // <ul>
    //   <li>First item</li>
    //   <li>Second item</li>
    //   <li>Third item</li>
    // </ul>`);
    window.print(`'''<h1>AppFlowyEditor</h1>
<h2>👋 <strong>Welcome to</strong> <strong><em><a href="appflowy.io">AppFlowy Editor</a></em></strong></h2>
  <p>AppFlowy Editor is a <strong>highly customizable</strong> <em>rich-text editor</em></p>
<hr />
<p><u>Here</u> is an example <del>your</del> you can give a try</p>
<br>
<span style="font-weight: bold;background-color: #cccccc;font-style: italic;">Span element</span>
<span style="font-weight: medium;text-decoration: underline;">Span element two</span>
</br>
<span style="font-weight: 900;text-decoration: line-through;">Span element three</span>
<a href="https://appflowy.io">This is an anchor tag!</a>
<img src="https://images.squarespace-cdn.com/content/v1/617f6f16b877c06711e87373/c3f23723-37f4-44d7-9c5d-6e2a53064ae7/Asset+10.png?format=1500w" />
<h3>Features!</h3>
<ul>
  <li>[x] Customizable</li>
  <li>[x] Test-covered</li>
  <li>[ ] more to come!</li>
</ul>
<ol>
  <li>First item</li>
  <li>Second item</li>
</ol>
<li>List element</li>
<blockquote>
  <p>This is a quote!</p>
</blockquote>
<code>
  Code block
</code>
<em>Italic one</em> <i>Italic two</i>
<b>Bold tag</b>
<img src="http://appflowy.io" alt="AppFlowy">
<p>You can also use <strong><em>AppFlowy Editor</em></strong> as a component to build your own app.</p>
<h3>Awesome features</h3>

<p>If you have questions or feedback, please submit an issue on Github or join the community along with 1000+ builders!</p>
  <h3>Checked Boxes</h3>
 <input type="checkbox" id="option2" checked> 
  <label for="option2">Option 2</label>
  <input type="checkbox" id="option3"> 
  <label for="option3">Option 3</label>
  '''`);
  };
  return (
    <Card>
      <Button
        type="danger"
        onClick={() => {
          handlePrint();
        }}
      >
        打印
      </Button>
      <div
        dangerouslySetInnerHTML={{
          __html: `<h1>AppFlowyEditor</h1>
      <h2>
        👋 <strong>Welcome to</strong>{" "}
        <strong>
          <em>
            <a href="appflowy.io">AppFlowy Editor</a>
          </em>
        </strong>
      </h2>
      <p>
        AppFlowy Editor is a <strong>highly customizable</strong> <em>rich-text editor</em>
      </p>
      <hr />
      <p>
        <u>Here</u> is an example <del>your</del> you can give a try
      </p>
      <br>
        <span style="font-weight: bold;background-color: #cccccc;font-style: italic;">Span element</span>
        <span style="font-weight: medium;text-decoration: underline;">Span element two</span>
      </br>
      <span style="font-weight: 900;text-decoration: line-through;">Span element three</span>
      <a href="https://appflowy.io">This is an anchor tag!</a>
      <img src="https://images.squarespace-cdn.com/content/v1/617f6f16b877c06711e87373/c3f23723-37f4-44d7-9c5d-6e2a53064ae7/Asset+10.png?format=1500w" />
      <h3>Features!</h3>
      <ul>
        <li>[x] Customizable</li>
        <li>[x] Test-covered</li>
        <li>[ ] more to come!</li>
      </ul>
      <ol>
        <li>First item</li>
        <li>Second item</li>
      </ol>
      <li>List element</li>
      <blockquote>
        <p>This is a quote!</p>
      </blockquote>
      <code>Code block</code>
      <em>Italic one</em> <i>Italic two</i>
      <b>Bold tag</b>
      <img src="http://appflowy.io" alt="AppFlowy" />
      <p>
        You can also use{" "}
        <strong>
          <em>AppFlowy Editor</em>
        </strong>{" "}
        as a component to build your own app.
      </p>
      <h3>Awesome features</h3>
      <p>
        If you have questions or feedback, please submit an issue on Github or join the community along with 1000+
        builders!
      </p>
      <h3>Checked Boxes</h3>
      <input type="checkbox" id="option2" checked />
      <label htmlFor="option2">Option 2</label>
      <input type="checkbox" id="option3" />
      <label htmlFor="option3">Option 3</label>`,
        }}
      />
    </Card>
  );
};

export default UtilsModule;
