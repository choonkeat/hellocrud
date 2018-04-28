// import React from 'react'
// import './App.css'
{{- range $table := .Tables}}
{{- $tableNameSingular := $table.Name | singular -}}
{{- $tableNamePlural := $table.Name | plural -}}
{{- $modelName := $tableNameSingular | titleCase -}}
{{- $modelNamePlural := $table.Name | plural | titleCase -}}
{{- $modelNameCamel := $tableNameSingular | camelCase}}
// import {{ $modelName }} from './{{ $tableNameSingular }}'
{{- end }}
// import { Switch, Route } from 'react-router'
// import { ApolloProvider } from 'react-apollo'
// import { ApolloClient } from 'apollo-client'
// import { HttpLink } from 'apollo-link-http'
// import { InMemoryCache } from 'apollo-cache-inmemory'
//
// const client = new ApolloClient({
//   link: new HttpLink({ uri: 'http://localhost:5000/graphql' }),
//   cache: new InMemoryCache()
// })
//
// const App = (props) => {
//   return (
//     <div>
//       <nav className='navbar navbar-expand-md navbar-dark bg-dark fixed-top'>
//         <a className='navbar-brand' href='/'>Navbar</a>
//         <button className='navbar-toggler' type='button' data-toggle='collapse' data-target='#navbarSupportedContent' aria-controls='navbarSupportedContent' aria-expanded='false' aria-label='Toggle navigation'>
//           <span className='navbar-toggler-icon' />
//         </button>
//
//         <div className='collapse navbar-collapse' id='navbarSupportedContent'>
//           <ul className='navbar-nav mr-auto'>
{{- range $table := .Tables}}
{{- $tableNameSingular := $table.Name | singular -}}
{{- $tableNamePlural := $table.Name | plural -}}
{{- $modelName := $tableNameSingular | titleCase -}}
{{- $modelNamePlural := $table.Name | plural | titleCase -}}
{{- $modelNameCamel := $tableNameSingular | camelCase}}
//             <li className='nav-item'>
//               <a className='nav-link' href='/{{ $tableNamePlural }}'>{{ $modelNamePlural }}</a>
//             </li>
{{- end }}
//           </ul>
//         </div>
//       </nav>
//       <ApolloProvider client={client}>
//         <Switch>
//           <Route exact path='/' render={() => <div />} />
{{- range $table := .Tables}}
{{- $tableNameSingular := $table.Name | singular -}}
{{- $tableNamePlural := $table.Name | plural -}}
{{- $modelName := $tableNameSingular | titleCase -}}
{{- $modelNamePlural := $table.Name | plural | titleCase -}}
{{- $modelNameCamel := $tableNameSingular | camelCase}}
//           <Route path='/{{ $tableNamePlural }}' render={() => <{{ $modelName }}.Crud history={props.history} />} />
{{- end }}
//         </Switch>
//       </ApolloProvider>
//     </div>
//   )
// }
//
// export default App
