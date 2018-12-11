<template>
  <div>
    <section class="btn-group">
      Change format: 
        <button @click="createRectangles">Create Rectangles</button> 
        <button @click="createCircles">Create Circles</button> 
        <button @click="createLines('curve')">Create Curves</button>
        <button @click="createLines('step')">Create Steps</button>
        <button @click="createStars">Create Stars</button>
    </section>
    <main ref="main"></main>
  </div>
</template>

<script>
import * as d3 from 'd3'
import { customerData } from './../mixins/customerData'

export default {
  data() {
    return {
      width: 600,
      height: 300,
      margin: { top: 20, bottom: 25, left: 25, right: 20 },
      svg: null,
      xScale: null,
      yScale: null,
      heightScale: null
    }
  },
  mixins: [customerData],
  methods: {
    initChart() {
      let vueThis = this

      // extent gets the lowest and highest values of that data
      var xExtent = d3.extent(vueThis.customerData, d => d.OrderNumber)
      this.xScale = d3
        .scaleLinear()
        .domain(xExtent)
        .range([this.margin.left, this.width - this.margin.right])

      // we don't use extent for price because we want to start at 0
      var yMax = d3.max(vueThis.customerData, d => d.Amount_Due)
      this.yScale = d3
        .scaleLinear()
        .domain([0, yMax])
        .range([this.height - this.margin.bottom, this.margin.top])
      this.heightScale = d3
        .scaleLinear()
        .domain([0, yMax])
        .range([0, this.height - this.margin.top - this.margin.bottom])

      // create the axis
      var xAxis = d3.axisBottom().scale(this.xScale)
      var yAxis = d3.axisLeft().scale(this.yScale)

      this.svg
        .append('g')
        .attr(
          'transform',
          `translate(${[0, this.height - this.margin.bottom]})`
        )
        .call(xAxis)

      this.svg
        .append('text')
        .attr(
          'transform',
          `translate(${this.width / 2},${this.height + this.margin.top})`
        )
        .style('text-anchor', 'middle')
        .text('Order Number')

      this.svg
        .append('g')
        .attr('transform', `translate(${[this.margin.left, 0]})`)
        .call(yAxis)

      this.svg
        .append('text')
        .attr('transform', 'rotate(-90)')
        .attr('y', 0 - this.margin.left)
        .attr('x', 0 - this.height / 2)
        .attr('dy', '1em')
        .style('text-anchor', 'middle')
        .text('Amount Due')

      //create a gradient to use wherever
      var mainGradient = this.svg
        .append('linearGradient')
        .attr('id', 'nicegradient')
      mainGradient
        .append('stop')
        .attr('class', 'start-color')
        .attr('offset', '0')
      mainGradient
        .append('stop')
        .attr('class', 'end-color')
        .attr('offset', '1')
    },
    createCircles() {
      d3.selectAll('.contain').remove()

      let vueThis = this
      return this.svg
        .append('g')
        .attr('class', 'contain')
        .selectAll('circle')
        .data(vueThis.customerData)
        .enter()
        .append('circle')
        .attr('cx', d => vueThis.xScale(d.OrderNumber))
        .attr('cy', d => vueThis.yScale(d.Amount_Due))
        .attr('r', d => d.Amount_Due / 5)
        .style('fill', 'none')
        .style('stroke', d => `hsl(${d.OrderNumber * 2.5 + 10}, 50%, 50%)`)
    },
    createRectangles() {
      d3.selectAll('.contain').remove()

      let vueThis = this
      return this.svg
        .append('g')
        .attr('class', 'contain')
        .selectAll('rect')
        .data(vueThis.customerData)
        .enter()
        .append('rect')
        .attr('width', 4)
        .attr('height', d => vueThis.heightScale(d.Amount_Due))
        .attr('x', d => vueThis.xScale(d.OrderNumber))
        .attr('y', d => vueThis.yScale(d.Amount_Due))
        .style('fill', d => `hsl(${d.OrderNumber * 2.5 + 10}, 50%, 50%)`)
        .style('stroke', 'white')
    },
    createLines(shape) {
      d3.selectAll('.contain').remove()
      let vueThis = this,
        currentShape = shape === 'curve' ? d3.curveCardinal : d3.curveStep

      let data = vueThis.customerData
      data.sort((a, b) => a.OrderNumber - b.OrderNumber)

      var valueline = d3
        .line()
        .x(d => vueThis.xScale(d.OrderNumber))
        .y(d => vueThis.yScale(d.Amount_Due))
        .curve(currentShape)

      return this.svg
        .append('g')
        .attr('class', 'contain')
        .append('path')
        .datum(data)
        .attr('d', valueline)
        .style('fill', 'none')
        .attr('stroke', 'url(#nicegradient)')
    },
    createStars() {
      d3.selectAll('.contain').remove()
      let vueThis = this

      let symbolGenerator = d3
        .symbol()
        .type(d3.symbolStar)
        .size(50)

      let pathData = symbolGenerator()

      return this.svg
        .append('g')
        .attr('class', 'contain')
        .selectAll('path')
        .data(vueThis.customerData)
        .enter()
        .append('path')
        .attr(
          'transform',
          d =>
            `translate(${vueThis.xScale(d.OrderNumber)}, ${vueThis.yScale(
              d.Amount_Due
            )})`
        )
        .attr('d', pathData)
        .style('fill', 'none')
        .style('stroke', d => `hsl(${d.OrderNumber * 2.5 + 10}, 50%, 50%)`)
    }
  },
  mounted() {
    this.svg = d3
      .select('main')
      .append('svg')
      .attr('viewBox', `-40 -40 ${this.width + 50} ${this.height + 100}`)

    this.initChart()
    this.createRectangles()
  }
}
</script>

<style lang="scss">
svg text {
  font-family: 'Avenir', sans-serif;
}

main {
  width: 70vw;
  margin: 0 15vw;
}

button {
  margin: -3px 10px 0;
  background: none;
  color: black;
  border: 1px solid black;
  border-radius: 5px;
  padding: 5px 10px 4px;
  text-transform: uppercase;
  font-size: 12px;
  letter-spacing: 0.05em;
  cursor: pointer;
  outline: 0;
  transition: 0.3s all ease;
  &:hover {
    background: #333;
    color: white;
  }
}

.btn-group {
  display: flex;
  justify-content: center;
  width: 100vw;
}

#nicegradient stop.start-color {
  stop-color: #5f2c82;
}

#nicegradient stop.end-color {
  stop-color: #0abfbc;
}
</style>