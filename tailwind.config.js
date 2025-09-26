module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js'
  ],
  theme: {
    extend: {
      colors: {
        'spirit-primary': 'var(--color-spirit-primary)',
        'spirit-secondary': 'var(--color-spirit-secondary)',
        'spirit-accent': 'var(--color-spirit-accent)',
        'spirit-light': 'var(--color-spirit-light)',
        'spirit-dark': 'var(--color-spirit-dark)',
        'nature-green': 'var(--color-nature-green)',
        'nature-brown': 'var(--color-nature-brown)',
      },
      boxShadow: {
        'spirit': 'var(--spirit-glow)',
      },
      animation: {
        'spirit-pulse': 'spirit-pulse 2s infinite',
      },
    },
  },
  plugins: [],
}