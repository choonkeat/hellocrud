import React from 'react'
import { graphql, compose } from 'react-apollo'
import gql from 'graphql-tag'
import { Form, Field } from 'react-final-form'
import { Switch, Route } from 'react-router'
import { Link } from 'react-router-dom'

// TupleForm for editing or creating a tuple
const TupleForm = (props) => {
  let onSubmit = (form) => {
    delete form.__typename
    {{- if .RailsTimestamps}}
    let now = new Date()
    {{- end}}
    let mutateInput = {
      variables: {
        input: { {{.TableName | ToCamel}}: { ...form{{if .RailsTimestamps}}, createdAt: now, updatedAt: now{{end}} } }
      }
    }
    if (props.current) {
      let formId = form.id
      delete form.id
      mutateInput.variables.input = {
        id: formId,
        {{.TableName | ToCamel}}Patch: { ...form{{if .RailsTimestamps}}, createdAt: now, updatedAt: now{{end}} }
      }
    }
    props.mutate(mutateInput).then(({ data }) => {
      props.history.push('/{{.TableName | ToPlural}}')
      props.data.refetch()
    }).catch((error) => {
      console.log('there was an error sending the query', error)
    })
    return false
  }

  return <div className='card-body'>
    <Link to='/{{.TableName | ToPlural}}'>&larr; {{.TableName | ToPlural | ToHuman}}</Link><h1 className='card-title'>{{.TableName | ToHuman}} #{props.current ? props.current.rowId : 'New'}</h1>
    <Form
      onSubmit={onSubmit}
      initialValues={props.current}
      render={({ handleSubmit, reset, submitting, pristine, values }) => (
        <form onSubmit={handleSubmit}>
          {(props.errors || []).map(err => {
            return <p>Error: {JSON.stringify(err)}</p>
          })}
          {props.current ? (<div>
            <input type='hidden' name='rowId' value={props.current.rowId} />
          </div>) : null}
          {{- range $key, $value := .ColumnNames }}{{- if ne $value "" }}
          <div className='form-group row'>
            <label className='col-sm-2 col-form-label'>{{ $value }}</label>
            <Field className='form-control col-sm-10' name='{{$key | ToCamel}}' component='input' type='text' placeholder='{{ $value }}' />
            <small className='form-text text-muted offset-sm-2'>tip: {{$key | ToCamel}}</small>
          </div>
          {{- end}}{{- end}}
          <div className='form-group row'>
            <div className='offset-sm-2'>
              <button className='btn btn-primary' type='submit' disabled={submitting || pristine}>Submit</button>
              &nbsp;<Link to='/{{.TableName | ToPlural}}'>Cancel</Link>
            </div>
          </div>
        </form>
      )}
    />
  </div>
}

// ShowTuple displays a tuple, be creative in your HTML
const ShowTuple = (props) => {
  return <div className='card-body'>
    <Link to='/{{.TableName | ToPlural}}'>&larr; {{.TableName | ToHuman | ToPlural}}</Link><h1 className='card-title'>{{.TableName | ToHuman }} #{props.current.rowId}</h1>
    <table>
      <tbody>{{range $key, $value := .ColumnNames }}{{if ne $value "" }}
        <tr>
          <th>{{$value}}</th>
          <td>{props.current.{{$key | ToCamel}}}</td>
        </tr>{{end}}{{end}}
      </tbody>
    </table>
    <Link to={`/{{.TableName | ToPlural}}/${props.current.id}/edit`}><button className='btn btn-secondary'>Edit</button></Link>
  </div>
}

// DeleteTuple is a button (or change it to something else)
const DeleteTuple = (props) => {
  let onClick = () => {
    props.delete{{.TableName | ToCamel | ToTitle}}({
      variables: {
        id: props.id
      }
    }).then(({ data }) => {
      props.data.refetch()
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
}

const ListTuples = (props) => {
  return <div className='card-body'>
    <Link to='/'>&larr; Home</Link><h1 className='card-title'>{{.TableName | ToPlural | ToHuman}}</h1>
    <div className='float-right'>
      <Link to='/{{.TableName | ToPlural}}/new'><button className='btn btn-primary'>New {{.TableName | ToHuman}} &hellip;</button></Link>
    </div>
    <table>
      <tbody>
        {((props.data.all{{.TableName | ToPlural | ToCamel | ToTitle}} && props.data.all{{.TableName | ToPlural | ToCamel | ToTitle}}.nodes) || []).map(row => {
          return <tr key={row.rowId}>
            <td><Link to={`/{{.TableName | ToPlural}}/${row.id}`}>{row.id}</Link></td>
            <td><Link to={`/{{.TableName | ToPlural}}/${row.id}/edit`}><button className='btn btn-secondary'>Edit</button></Link></td>
            <td><DeleteTuple id={row.id} {...props} /></td>
          </tr>
        })}
      </tbody>
    </table>
  </div>
}

// seems like `compose` cannot deal with 2 gql`query`?
// so we're breaking it out
const GetTuple = graphql(gql`
  query {{.TableName | ToCamel }}($rowid: ID!){
    {{.TableName | ToCamel }}(id: $rowid) {
      {{- range $key, $value := .ColumnNames }}
      {{$key | ToCamel}}
      {{- end}}
    }
  }
`)((props) => {
  if (props.loading || (!props.data.{{.TableName | ToCamel }})) {
    return <p>Loading&hellip;</p>
  }
  return <div>
    {React.Children.map(props.children, (child) => {
      return React.cloneElement(child, {current: props.data.{{.TableName | ToCamel }}})
    })}
  </div>
})

const Component = compose(
  graphql(gql`
    query {
      all{{.TableName | ToPlural | ToCamel | ToTitle}}(orderBy:ID_DESC) {
        totalCount
        nodes {
          {{- range $key, $value := .ColumnNames }}
          {{$key | ToCamel}}
          {{- end}}
        }
      }
    }
  `, {name: 'data'}),
  graphql(gql`
    mutation delete{{.TableName | ToCamel | ToTitle}}($id: ID!) {
      delete{{.TableName | ToCamel | ToTitle}}(input:{id:$id}) {
        {{.TableName | ToCamel}} {
          {{- range $key, $value := .ColumnNames }}
          {{$key | ToCamel}}
          {{- end}}
        }
      }
    }
  `, {name: 'delete{{.TableName | ToCamel | ToTitle}}'}),
  graphql(gql`
    mutation create{{.TableName | ToCamel | ToTitle}}($input: Create{{.TableName | ToCamel | ToTitle}}Input!) {
      create{{.TableName | ToCamel | ToTitle}}(input: $input) {
        {{.TableName | ToCamel}} {
          {{- range $key, $value := .ColumnNames }}
          {{$key | ToCamel}}
          {{- end}}
        }
      }
    }
  `, {name: 'create{{.TableName | ToCamel | ToTitle}}'}),
  graphql(gql`
    mutation update{{.TableName | ToCamel | ToTitle}}($input: Update{{.TableName | ToCamel | ToTitle}}Input!) {
      update{{.TableName | ToCamel | ToTitle}}(input: $input) {
        {{.TableName | ToCamel}} {
          {{- range $key, $value := .ColumnNames }}
          {{$key | ToCamel}}
          {{- end}}
        }
      }
    }
  `, {name: 'update{{.TableName | ToCamel | ToTitle}}'})
)((props) => {
  return <div>
    <Switch>
      <Route exact path='/{{.TableName | ToPlural}}' render={() => <ListTuples {...props} />} />
      <Route exact path='/{{.TableName | ToPlural}}/new' render={() => <TupleForm {...props} mutate={props.create{{.TableName | ToCamel | ToTitle}}} />} />
      <Route path='/{{.TableName | ToPlural}}/:rowid/edit' render={({ match: { params } }) => {
        return <GetTuple rowid={params.rowid}>
          <TupleForm {...props} params={params} mutate={props.update{{.TableName | ToCamel | ToTitle}}} />
        </GetTuple>
      }} />
      <Route path='/{{.TableName | ToPlural}}/:rowid' render={({ match: { params } }) => {
        return <GetTuple rowid={params.rowid}>
          <ShowTuple {...props} params={params} />
        </GetTuple>
      }} />
    </Switch>
  </div>
})

export default Component
