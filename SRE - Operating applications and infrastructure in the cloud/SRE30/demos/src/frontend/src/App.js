import React from "react";
import { render } from "react-dom";
import Nav from "./Nav";
import ProductTable from "./ProductTable";

const App = () => (
  <div>
    <Nav />
    <ProductTable />
  </div>
);

render(<App />, document.getElementById("root"));
