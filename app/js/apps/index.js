import { Component } from 'react'

export class FirstFrameGif extends Component {
  constructor(props) {
    super(props)

    this.state = {
      run: false
    }
  }

  @autobind
  mouseEnter() {
    this.setState({ run: true })
  }

  @autobind
  mouseLeave() {
    this.setState({ run: false })
  }

  render() {
    let runStyle = { height: ( this.state.run ? '100%' : '0px' ) },
        firstStyle = { height: ( this.state.run ? '0px': '100%' ) }

    return (
      <div>
        <img src={ `/images/gifs/${ this.props.filename }` } onMouseLeave={ this.mouseLeave } style={ runStyle } />
        <img src={ `/images/gifs/first/${ this.props.filename }` } onMouseEnter={ this.mouseEnter } style={ firstStyle } />
      </div>
    )
  }
}
