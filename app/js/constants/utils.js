export function createConstants(...constants) {
  return constants.reduce((memo, constant) => {
    memo[constant] = constant
    return memo
  }, {})
}
