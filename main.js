import { Elm } from './src/Main.elm'
import flags from './flags.json'

Elm.Main.init({
	node: document.querySelector('main'),
	flags: flags
})
