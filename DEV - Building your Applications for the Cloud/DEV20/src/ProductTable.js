import React from "react";
import { Column, Table, AutoSizer, InfiniteLoader } from "react-virtualized";
import Modal from "./Modal";
import ProductDetails from "./ProductDetails";

class ProductTable extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      rows: [],
      start: 1,
      stop: 10,
      selectedRow: null
    };

    this.lastRequestedPage = -1;

    this.modRowsShowing = this.modRowsShowing.bind(this);
    this.getInventory = this.getInventory.bind(this);
    this.handleRowClick = this.handleRowClick.bind(this);
    this.handleModalClick = this.handleModalClick.bind(this);
    this.closeModal = this.closeModal.bind(this);
    this.isRowLoaded = this.isRowLoaded.bind(this);
    this.fetchRows = this.fetchRows.bind(this);
  }
  componentDidMount() {
    this.fetchRows({ stopIndex: 1 });
  }
  fetchRows({ stopIndex }) {
    const page = Math.round(stopIndex / 500);

    if (page <= this.lastRequestedPage || stopIndex >= this.state.totalSize) {
      return;
    }

    this.lastRequestedPage = page;

    fetch(
      `${
        process.env.PRODUCT_SERVICE_BASE_URL
      }/api/products?pageSize=500&page=${page}`
    )
      .then(data => data.json())
      .then(({ items, size }) => {
        this.setState({ rows: this.state.rows.concat(items), totalSize: size });
        this.interval = Date.now() + 2000;

        requestAnimationFrame(this.getInventory);
      });
  }
  getInventory() {
    if (this.interval > Date.now()) {
      requestAnimationFrame(this.getInventory);
      return;
    }

    // if (this.state.rows.length - this.state.stop <= 250) {
    //   this.fetchRows(Math.ceil(this.state.rows.length / 500));
    // }

    const nums = Array.from({ length: this.state.stop - this.state.start })
      .map((_, index) => index + this.state.start + 1)
      .join(",");
    fetch(
      `${process.env.INVENTORY_SERVICE_BASE_URL}/api/inventory?skus=${nums}`
    )
      .then(data => data.json())
      .then(skus => {
        for (let i = 0; i < skus.length; i++) {
          // cloning a list of 100,000 is bad
          this.state.rows[+skus[i].sku - 1].inventory = skus[i].quantity; // eslint-disable-line
        }

        this.forceUpdate();
        this.interval = Date.now() + 5000;
        requestAnimationFrame(this.getInventory);
      }, console.error);
  }
  modRowsShowing({ overscanStartIndex, overscanStopIndex }) {
    this.setState({
      start: overscanStartIndex,
      stop: overscanStopIndex
    });
  }
  handleRowClick(rowEvent) {
    this.setState({ selectedRow: rowEvent.rowData });
  }
  handleModalClick(e) {
    if (e.target.id === "modal-interior") {
      this.closeModal();
    }
  }
  closeModal() {
    this.setState({ selectedRow: null });
  }
  isRowLoaded({ index }) {
    return !!this.state.rows[index];
  }
  render() {
    return (
      <div className="table-container">
        <InfiniteLoader
          rowCount={this.state.totalSize}
          loadMoreRows={this.fetchRows}
          isRowLoaded={this.isRowLoaded}
        >
          {({ onRowsRendered, registerChild }) => (
            <AutoSizer>
              {({ height, width }) => (
                <Table
                  width={width}
                  height={height}
                  headerHeight={60}
                  rowHeight={60}
                  rowCount={this.state.rows.length}
                  ref={registerChild}
                  rowGetter={({ index }) => this.state.rows[index]}
                  onRowsRendered={data => {
                    this.modRowsShowing(data);
                    onRowsRendered(data);
                  }}
                  rowClassName={({ index }) =>
                    index % 2 ? "row-even" : "row-odd"
                  }
                  headerClassName="row-header"
                  onRowClick={this.handleRowClick}
                >
                  <Column width={100} label="ID" dataKey="id" />
                  <Column width={300} label="Name" dataKey="name" />
                  <Column width={300} label="SKU" dataKey="sku" />
                  <Column width={100} label="Price" dataKey="price" />
                  <Column width={200} label="Supplier" dataKey="supplierName" />
                  <Column width={200} label="Inventory" dataKey="inventory" />
                </Table>
              )}
            </AutoSizer>
          )}
        </InfiniteLoader>
        {!this.state.selectedRow ? null : (
          <Modal>
            <div
              role="none"
              onClick={this.handleModalClick}
              id="modal-interior"
            >
              <div>
                <ProductDetails {...this.state.selectedRow} />
                <div className="buttons">
                  <button className="exit-button" onClick={this.closeModal}>
                    Close
                  </button>
                </div>
              </div>
            </div>
          </Modal>
        )}
      </div>
    );
  }
}

export default ProductTable;
