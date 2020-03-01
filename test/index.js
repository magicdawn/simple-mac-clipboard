const should = require('should')
const clip = require('..')
const {clipboard} = require('electron')

describe('write', () => {
  it.skip('demo ', () => {
    // demo code
  })

  it('.clear ', () => {
    clip.clear()
    clipboard.readText().length.should.equal(0)
  })
})
