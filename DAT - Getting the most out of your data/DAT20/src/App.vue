<template>
  <div id="app">
    <BaseChart />
  </div>
</template>

<script>
import BaseChart from './components/BaseChart.vue'

export default {
  name: 'app',
  components: {
    BaseChart
  }
}
</script>

<style lang="scss">
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
