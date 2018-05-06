/*sqlboiler2other
{{- $dot := . -}}
{{- $tableNameSingular := .Table.Name | singular -}}
{{- $tableNamePlural := .Table.Name | plural -}}
{{- $modelName := $tableNameSingular | titleCase -}}
{{- $modelNamePlural := $modelName | plural -}}
{{- $modelNameCamel := $tableNameSingular | camelCase -}}
{{- $pkColNames := .Table.PKey.Columns -}}

import React from 'react'
import { graphql } from 'react-apollo'
import gql from 'graphql-tag'
import { Form, Field } from 'react-final-form'
import { Switch, Route } from 'react-router'
import { Link } from 'react-router-dom'

// TupleForm for editing or creating a tuple
export class TupleForm extends React.Component {
  constructor (props) {
    super(props)
    this.state = { errors: [] }
    this.onSubmit = this.onSubmit.bind(this)
  }

  onSubmit (form) {
    delete form.__typename
    for (var k in form) {
      if (form.hasOwnProperty(k) && k.endsWith('ID') && ('' + form[k]).match(/^[-]?\d+\.?\d*$/)) {
        form[k] = +form[k]
      }
    }
    let mutateInput = {
      variables: {
        input: { ...form }
      }
    }
    if (this.props.current && form.id) {
      let formId = form.id
      delete form.id
      mutateInput.variables = {
        id: formId,
        input: { ...form }
      }
    }

    let setState = this.setState.bind(this)
    this.props.mutate(mutateInput).then((...args) => {
      if (this.props.search{{ $modelNamePlural }}Data && this.props.search{{ $modelNamePlural }}Data.refetch) this.props.search{{ $modelNamePlural }}Data.refetch()
      this.props.history.push('/{{ $tableNamePlural }}')
    }).catch((error) => {
      setState({ errors: [error] })
    })
    return false
  }

  render () {
    let state = this.state
    let current = this.props.current

    return <div className='card-body'>
      <Link to='/{{ $tableNamePlural }}'>&larr; {{ $modelNamePlural }}</Link><h1 className='card-title'>{current && current.id ? 'Edit' : 'New'} {{ $modelName }}</h1>
      <Form
        onSubmit={this.onSubmit}
        initialValues={current}
        render={({ handleSubmit, reset, submitting, pristine, values }) => (
          <form onSubmit={handleSubmit}>
            {(state.errors || []).map((errObject, index) => {
              return <div key={`error-{index}`} className='alert alert-danger'>
                {errObject.message}
              </div>
            })}
            {current && current.rowId ? (<div>
              <input type='hidden' name='rowId' value={current.rowId} />
            </div>) : null}
{{ range $column := .Table.Columns -}}
{{ if eq $column.Name "created_at" -}}
{{ else if eq $column.Name "updated_at" -}}
{{ else if eq $column.Name "id" -}}
{{ else -}}
            <div className='form-group row'>
              <label className='col-sm-2 col-form-label'>{{ $column.Name | camelCase }}</label>
              <Field className='form-control col-sm-10' name='{{ $column.Name | camelCase }}' component='input' type='text' placeholder='{{ $column.Name }}' />
              <small className='form-text text-muted offset-sm-2'>tip: {{ $column.Name | camelCase }}</small>
            </div>
{{ end -}}
{{ end -}}
            <div className='form-group row'>
              <div className='offset-sm-2'>
                <button className='btn btn-primary' type='submit' disabled={submitting || pristine}>Submit{submitting ? '...' : null}</button>
                &nbsp;<Link to='/{{ $tableNamePlural }}'>Cancel</Link>
              </div>
            </div>
          </form>
        )}
      />
    </div>
  }
}

// ShowTuple displays a tuple, be creative in your HTML
export const ShowTuple = ({ current }) => {
  return <div className='card-body'>
    <Link to='/{{ $tableNamePlural }}'>&larr; {{ $modelNamePlural }} </Link><h1 className='card-title'>{{ $modelName }} #{current.rowId}</h1>
    <table>
      <tbody>
{{ range $column := .Table.Columns -}}
        <tr>
          <th>{{ $column.Name | camelCase }}</th>
          <td>{current.{{ $column.Name | camelCase }}}</td>
        </tr>
{{ end -}}
      </tbody>
    </table>
    <Link to={`/{{ $tableNamePlural }}/${current.id}/edit`}><button className='btn btn-secondary'>Edit</button></Link>
  </div>
}

// DeleteTuple is a button (or change it to something else)
export const DeleteTuple = graphql(gql`
  mutation delete{{ $modelName }}ByID($id: ID!) {
    delete{{ $modelName }}ByID(id:$id) {
      rowId
{{ range $column := .Table.Columns -}}
      {{ $column.Name | camelCase }}
{{ end -}}
    }
  }
`, {name: 'delete{{ $modelName }}ByID'})(({ id, delete{{ $modelName }}ByID, search{{ $modelNamePlural }}Data }) => {
  let onClick = () => {
    delete{{ $modelName }}ByID({
      variables: {
        id: id
      }
    }).then((...args) => {
      if (search{{ $modelNamePlural }}Data && search{{ $modelNamePlural }}Data.refetch) search{{ $modelNamePlural }}Data.refetch()
    }).catch((error) => {
      console.log('there was an error sending the query', JSON.stringify(error))
    })
    return false
  }

  return <div>
    <button className='btn btn-danger' onClick={onClick}>
      Delete
    </button>
  </div>
})

export const ListTuples = ({search{{ $modelNamePlural }}Data}) => {
  return <div className='card-body'>
    <Link to='/'>&larr; Home</Link><h1 className='card-title'>{{ $modelNamePlural }}</h1>
    <div className='float-right'>
      <Link to='/{{ $tableNamePlural }}/new'><button className='btn btn-primary'>New {{ $modelName }} &hellip;</button></Link>
    </div>
    <table className='table table-hover'>
      <thead>
        <tr>
{{ range $column := .Table.Columns -}}
          <th>{{ $column.Name | camelCase }}</th>
{{ end -}}
          <th />
          <th />
        </tr>
      </thead>
      <tbody>
        {((search{{ $modelNamePlural }}Data.search{{ $modelNamePlural }} && search{{ $modelNamePlural }}Data.search{{ $modelNamePlural }}.nodes) || []).map(row => {
          return <tr key={row.rowId}>
{{ range $column := .Table.Columns -}}
            <td><Link to={`/{{ $tableNamePlural }}/${row.id}`}>{row.{{ $column.Name | camelCase }}}</Link></td>
{{ end -}}
            <td><Link to={`/{{ $tableNamePlural }}/${row.id}/edit`}><button className='btn btn-secondary'>Edit</button></Link></td>
            <td><DeleteTuple id={row.id} search{{ $modelNamePlural }}Data={search{{ $modelNamePlural }}Data} /></td>
          </tr>
        })}
      </tbody>
    </table>
  </div>
}

// seems like `compose` cannot deal with 2 gql`query`?
// so we're breaking it out
export const GetTuple = graphql(gql`
  query {{ $modelNameCamel }}($rowid: ID!){
    {{ $modelNameCamel }}ByID(id: $rowid) {
      rowId
{{ range $column := .Table.Columns -}}
      {{ $column.Name | camelCase }}
{{ end -}}
    }
  }
`)(({ loading, data, children }) => {
  if (loading || (!data.{{ $modelNameCamel }}ByID)) {
    return <p>Loading&hellip;</p>
  }
  return <div>
    {React.Children.map(children, (child) => {
      return React.cloneElement(child, {current: data.{{ $modelNameCamel }}ByID})
    })}
  </div>
})

export const Create = graphql(gql`
  mutation create{{ $modelName }}($input: Create{{ $modelName }}Input!) {
    create{{ $modelName }}(input: $input) {
      rowId
{{ range $column := .Table.Columns -}}
      {{ $column.Name | camelCase }}
{{ end -}}
    }
  }
`, {name: 'create{{ $modelName }}'})(({current, history, search{{ $modelNamePlural }}Data, create{{ $modelName }}}) => {
  return <TupleForm current={current} history={history} search{{ $modelNamePlural }}Data={search{{ $modelNamePlural }}Data} mutate={create{{ $modelName }}} />
})

export const Edit = graphql(gql`
  mutation update{{ $modelName }}ByID($id: ID!, $input: Update{{ $modelName }}Input!) {
    update{{ $modelName }}ByID(id: $id, input: $input) {
      rowId
{{ range $column := .Table.Columns -}}
      {{ $column.Name | camelCase }}
{{ end -}}
    }
  }
`, {name: 'update{{ $modelName }}ByID'})(({current, history, search{{ $modelNamePlural }}Data, update{{ $modelName }}ByID}) => {
  return <TupleForm current={current} history={history} search{{ $modelNamePlural }}Data={search{{ $modelNamePlural }}Data} mutate={update{{ $modelName }}ByID} />
})

export const Crud = graphql(gql`
  query search{{ $modelNamePlural }}($search: Search{{ $modelName }}Input){
    search{{ $modelNamePlural }}(pageSize: 30, input: $search) {
      nodes {
        rowId
{{ range $column := .Table.Columns -}}
        {{ $column.Name | camelCase }}
{{ end -}}
      }
    }
  }
`, {name: 'search{{ $modelNamePlural }}Data'})(({search, history, search{{ $modelNamePlural }}Data}) => {
  return <div>
    <Switch>
      <Route exact path='/{{ $tableNamePlural }}' render={() => <ListTuples history={history} search{{ $modelNamePlural }}Data={search{{ $modelNamePlural }}Data} search={search} />} />
      <Route exact path='/{{ $tableNamePlural }}/new' render={() => <Create history={history} search{{ $modelNamePlural }}Data={search{{ $modelNamePlural }}Data} />} />
      <Route path='/{{ $tableNamePlural }}/:rowid/edit' render={({ match: { params } }) => {
        return <GetTuple rowid={params.rowid}><Edit history={history} params={params} /></GetTuple>
      }} />
      <Route path='/{{ $tableNamePlural }}/:rowid' render={({ match: { params } }) => {
        return <GetTuple rowid={params.rowid}>
          <ShowTuple params={params} />
        </GetTuple>
      }} />
    </Switch>
  </div>
})

const Component = {
  Crud: Crud,
  List: graphql(gql`
    query search{{ $modelNamePlural }}($search: Search{{ $modelName }}Input){
      search{{ $modelNamePlural }}(pageSize: 30, input: $search) {
        nodes {
          rowId
          id
          postID
          author
          body
          notes
          createdAt
          updatedAt
        }
      }
    }
  `, {name: 'search{{ $modelNamePlural }}Data'})(props => <ListTuples {...props} />),
  Create: Create,
  Edit: Edit
}

export default Component
sqlboiler2other*/
