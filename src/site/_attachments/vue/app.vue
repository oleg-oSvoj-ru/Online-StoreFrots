<template lang="pug">
div
  p {{ greeting }} World!
  OtherComponent
</template>

<script lang="coffee-script">
console.log "Hello App.vue"
</script>

<style lang="stylus" scoped>
p
  font-size 2em
  text-align center
</style>
