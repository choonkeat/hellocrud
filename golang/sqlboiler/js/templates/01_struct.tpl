{{- $dot := . -}}
{{- $tableNameSingular := .Table.Name | singular -}}
{{- $tableNamePlural := .Table.Name | plural -}}
{{- $modelName := $tableNameSingular | titleCase -}}
{{- $modelNamePlural := $modelName | plural -}}
{{- $modelNameCamel := $tableNameSingular | camelCase -}}
{{- $pkColNames := .Table.PKey.Columns -}}

// import React from 'react'
// import { graphql, compose } from 'react-apollo'
// import gql from 'graphql-tag'
// import { Form, Field } from 'react-final-form'
// import { Switch, Route } from 'react-router'
// import { Link } from 'react-router-dom'
//
// // TupleForm for editing or creating a tuple
// const TupleForm = ({ current, mutate, history, data, errors }) => {
//   let onSubmit = (form) => {
//     delete form.__typename
//     for (var k in form) {
//       if (form.hasOwnProperty(k) && k.endsWith('ID') && ('' + form[k]).match(/^[-]?\d+\.?\d*$/)) {
//         form[k] = +form[k]
//       }
//     }
//     let mutateInput = {
//       variables: {
//         input: { ...form }
//       }
//     }
//     if (current) {
//       let formId = form.id
//       delete form.id
//       mutateInput.variables = {
//         id: formId,
//         input: { ...form }
//       }
//     }
//     mutate(mutateInput).then(({ data }) => {
//       history.push('/{{ $tableNamePlural }}')
//       data.refetch()
//     }).catch((error) => {
//       console.log('there was an error sending the query', error)
//     })
//     return false
//   }
//
//   return <div className='card-body'>
//     <Link to='/{{ $tableNamePlural }}'>&larr; {{ $modelName | plural }}</Link><h1 className='card-title'>{{ $modelName }} #{current ? current.rowId : 'New'}</h1>
//     <Form
//       onSubmit={onSubmit}
//       initialValues={current}
//       render={({ handleSubmit, reset, submitting, pristine, values }) => (
//         <form onSubmit={handleSubmit}>
//           {(errors || []).map(err => {
//             return <p>Error: {JSON.stringify(err)}</p>
//           })}
//           {current ? (<div>
//             <input type='hidden' name='rowId' value={current.rowId} />
//           </div>) : null}
{{ range $column := .Table.Columns -}}
{{ if eq $column.Name "created_at" -}}
{{ else if eq $column.Name "updated_at" -}}
{{ else if eq $column.Name "id" -}}
{{ else -}}
//           <div className='form-group row'>
//             <label className='col-sm-2 col-form-label'>{{ $column.Name | camelCase }}</label>
//             <Field className='form-control col-sm-10' name='{{ $column.Name | camelCase }}' component='input' type='text' placeholder='{{ $column.Name }}' />
//             <small className='form-text text-muted offset-sm-2'>tip: {{ $column.Name | camelCase }}</small>
//           </div>
{{ end -}}
{{ end -}}
//           <div className='form-group row'>
//             <div className='offset-sm-2'>
//               <button className='btn btn-primary' type='submit' disabled={submitting || pristine}>Submit{submitting ? '...' : null}</button>
//               &nbsp;<Link to='/{{ $tableNamePlural }}'>Cancel</Link>
//             </div>
//           </div>
//         </form>
//       )}
//     />
//   </div>
// }
//
// // ShowTuple displays a tuple, be creative in your HTML
// const ShowTuple = ({ current }) => {
//   return <div className='card-body'>
//     <Link to='/{{ $tableNamePlural }}'>&larr; {{ $modelName | plural }} </Link><h1 className='card-title'>{{ $modelName }} #{current.rowId}</h1>
//     <table>
//       <tbody>
{{ range $column := .Table.Columns -}}
//         <tr>
//           <th>{{ $column.Name | camelCase }}</th>
//           <td>{current.{{ $column.Name | camelCase }}}</td>
//         </tr>
{{ end -}}
//       </tbody>
//     </table>
//     <Link to={`/{{ $tableNamePlural }}/${current.id}/edit`}><button className='btn btn-secondary'>Edit</button></Link>
//   </div>
// }
//
// // DeleteTuple is a button (or change it to something else)
// const DeleteTuple = ({ id, delete{{ $modelName }}ByID, data }) => {
//   let onClick = () => {
//     delete{{ $modelName }}ByID({
//       variables: {
//         id: id
//       }
//     }).then(({ data }) => {
//       data.refetch()
//     }).catch((error) => {
//       console.log('there was an error sending the query', JSON.stringify(error))
//     })
//     return false
//   }
//
//   return <div>
//     <button className='btn btn-danger' onClick={onClick}>
//       Delete
//     </button>
//   </div>
// }
//
// const ListTuples = (props) => {
//   return <div className='card-body'>
//     <Link to='/'>&larr; Home</Link><h1 className='card-title'>{{ $modelName | plural }}</h1>
//     <div className='float-right'>
//       <Link to='/{{ $tableNamePlural }}/new'><button className='btn btn-primary'>New {{ $modelName }} &hellip;</button></Link>
//     </div>
//     <table className='table table-hover'>
//       <thead>
//         <tr>
{{ range $column := .Table.Columns -}}
//           <th>{{ $column.Name | camelCase }}</th>
{{ end -}}
//           <th />
//           <th />
//         </tr>
//       </thead>
//       <tbody>
//         {((props.data.all{{ $modelNamePlural }} && props.data.all{{ $modelNamePlural }}.nodes) || []).map(row => {
//           return <tr key={row.rowId}>
{{ range $column := .Table.Columns -}}
//             <td><Link to={`/{{ $tableNamePlural }}/${row.id}`}>{row.{{ $column.Name | camelCase }}}</Link></td>
{{ end -}}
//             <td><Link to={`/{{ $tableNamePlural }}/${row.id}/edit`}><button className='btn btn-secondary'>Edit</button></Link></td>
//             <td><DeleteTuple id={row.id} {...props} /></td>
//           </tr>
//         })}
//       </tbody>
//     </table>
//   </div>
// }
//
// // seems like `compose` cannot deal with 2 gql`query`?
// // so we're breaking it out
// const GetTuple = graphql(gql`
//   query {{ $modelNameCamel }}($rowid: ID!){
//     {{ $modelNameCamel }}ByID(id: $rowid) {
//       id
//       rowId
{{ range $column := .Table.Columns -}}
//       {{ $column.Name | camelCase }}
{{ end -}}
//     }
//   }
// `)(({ loading, data, children }) => {
//   if (loading || (!data.{{ $modelNameCamel }}ByID)) {
//     return <p>Loading&hellip;</p>
//   }
//   return <div>
//     {React.Children.map(children, (child) => {
//       return React.cloneElement(child, {current: data.{{ $modelNameCamel }}ByID})
//     })}
//   </div>
// })
//
// const Component = compose(
//   graphql(gql`
//     query {
//       all{{ $modelNamePlural }}(pageSize: 30) {
//         nodes {
//           id
//           rowId
{{ range $column := .Table.Columns -}}
//           {{ $column.Name | camelCase }}
{{ end -}}
//         }
//       }
//     }
//   `, {name: 'data'}),
//   graphql(gql`
//     mutation delete{{ $modelName }}ByID($id: ID!) {
//       delete{{ $modelName }}ByID(id:$id) {
//         id
//         rowId
{{ range $column := .Table.Columns -}}
//         {{ $column.Name | camelCase }}
{{ end -}}
//       }
//     }
//   `, {name: 'delete{{ $modelName }}ByID'}),
//   graphql(gql`
//     mutation create{{ $modelName }}($input: Create{{ $modelName }}Input!) {
//       create{{ $modelName }}(input: $input) {
//         id
//         rowId
{{ range $column := .Table.Columns -}}
//         {{ $column.Name | camelCase }}
{{ end -}}
//       }
//     }
//   `, {name: 'create{{ $modelName }}'}),
//   graphql(gql`
//     mutation update{{ $modelName }}ByID($id: ID!, $input: Update{{ $modelName }}Input!) {
//       update{{ $modelName }}ByID(id: $id, input: $input) {
//         id
//         rowId
{{ range $column := .Table.Columns -}}
//         {{ $column.Name | camelCase }}
{{ end -}}
//       }
//     }
//   `, {name: 'update{{ $modelName }}ByID'})
// )((props) => {
//   return <div>
//     <Switch>
//       <Route exact path='/{{ $tableNamePlural }}' render={() => <ListTuples {...props} />} />
//       <Route exact path='/{{ $tableNamePlural }}/new' render={() => <TupleForm {...props} mutate={props.create{{ $modelName }}} />} />
//       <Route path='/{{ $tableNamePlural }}/:rowid/edit' render={({ match: { params } }) => {
//         return <GetTuple rowid={params.rowid}>
//           <TupleForm {...props} params={params} mutate={props.update{{ $modelName }}ByID} />
//         </GetTuple>
//       }} />
//       <Route path='/{{ $tableNamePlural }}/:rowid' render={({ match: { params } }) => {
//         return <GetTuple rowid={params.rowid}>
//           <ShowTuple {...props} params={params} />
//         </GetTuple>
//       }} />
//     </Switch>
//   </div>
// })
//
// export default Component
