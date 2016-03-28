window.$ = $
window.jQuery = $

// Helper cause its nice to have this as a global
window._ = _

window.React = React
window.ReactDOM = ReactDOM

// And now somewhere to store lots of useless info
window.AppData = {}

import * as apps from './apps'

let components = [...document.getElementsByClassName('react-component')]
components.forEach( elm => {
  let name = elm.dataset.react

  let data = _.merge({}, JSON.parse(elm.dataset.payload))

  let component = React.createElement(apps[name], data)

  ReactDOM.render(component, elm)
})
