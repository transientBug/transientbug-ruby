import { applyMiddleware, compose, createStore } from 'redux'

import { syncHistory } from 'react-router-redux'

import { middleware as awaitMiddleware } from 'redux-await'
import createLogger from 'redux-logger'
import analytics from 'redux-analytics'

import history from '../history'

function analyticsTracker(type, payload) {
  console.log(`Analytics for ${ type }:`, payload)
}

export default function configStore(reducer, initialState) {
  const logger = createLogger({ collapsed: true })

  const analyticsMiddleware = analytics(({ type, payload }) => analyticsTracker(type, payload))
  const reduxRouterMiddleware = syncHistory(history)

  const store = compose(
    applyMiddleware( awaitMiddleware, reduxRouterMiddleware, analyticsMiddleware, logger ),
    window.devToolsExtension ? window.devToolsExtension() : f => f
  )(createStore)(reducer, initialState)

  reduxRouterMiddleware.listenForReplays(store)

  return store
}
