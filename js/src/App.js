import React from 'react'
import './App.css'
import Crud from './crud'
import Thing from './thing'
import { Switch, Route } from 'react-router'
import { ApolloProvider } from 'react-apollo'
import { ApolloClient } from 'apollo-client'
import { HttpLink } from 'apollo-link-http'
import { InMemoryCache } from 'apollo-cache-inmemory'

const client = new ApolloClient({
  link: new HttpLink({ uri: 'http://localhost:5000/graphql' }),
  cache: new InMemoryCache()
})

const App = (props) => {
  return (
    <div>
      <ApolloProvider client={client}>
        <Switch>
          <Route exact path='/' render={() => <Crud />} />
          <Route path='/' render={() => <Thing history={props.history} />} />
        </Switch>
      </ApolloProvider>
    </div>
  )
}

export default App
