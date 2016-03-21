import { createSelector } from 'reselect'

// Most of these are just small building blocks, so you'll likely have to
// combine them some more to get just what you want for data.

// Factories for common keys, such as errors and fetching properties
export const errorsSelectorFactory = location => {
  return createSelector(state => state, (state) => ( state[location].errors ))
}

export const fetchingSelectorFactory = location => {
  return createSelector(state => state, (state) => ( state[location].fetching ))
}

// Basic selectors
export const idSelector = state => state.params.id
