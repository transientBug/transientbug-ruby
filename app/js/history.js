import createHistory from 'history/lib/createBrowserHistory'
import { useBasename } from 'history'

const basename = document.body.dataset.reactRouterUrl || '/'

export default useBasename(createHistory)({
  basename: basename
})
