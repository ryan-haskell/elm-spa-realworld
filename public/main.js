// Initial data passed to Elm (should match `Flags` defined in `Shared.elm`)
// https://guide.elm-lang.org/interop/flags.html
var flags = {
  user: JSON.parse(localStorage.getItem('user')) || null
}

// Start our Elm application
var app = Elm.Main.init({ flags: flags })

// Ports go here
// https://guide.elm-lang.org/interop/ports.html
app.ports.outgoing.subscribe(({ tag, data }) => {
  switch (tag) {
    case 'saveUser':
      return localStorage.setItem('user', JSON.stringify(data))
    default:
      return console.warn(`Unrecognized Port`, tag)
  }
})