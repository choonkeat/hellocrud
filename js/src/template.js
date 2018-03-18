var _ = require('lodash')
_.mixin(require('lodash-inflection'))

const humanize = (s) => _.startCase(s)

const Template = (props) => {
  if (!props.table) return null
  let fields = props.fields || []

  return `
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
    ${props.timestamps ? 'let now = new Date();' : ''}
    let mutateInput = {
      variables: {
        input: { ...form${props.timestamps ? ', createdAt: now, updatedAt: now' : ''} }
      }
    }
    if (props.current) {
      let formId = form.id
      delete form.id
      mutateInput.variables = {
        id: formId,
        input: { ...form${props.timestamps ? ', createdAt: now, updatedAt: now' : ''} }
      }
    }
    props.mutate(mutateInput).then(({ data }) => {
      props.history.push('/${_.snakeCase(_.pluralize(props.table))}')
      props.data.refetch()
    }).catch((error) => {
      console.log('there was an error sending the query', error)
    })
    return false
  }

  return <div className='card-body'>
    <Link to='/${_.snakeCase(_.pluralize(props.table))}'>&larr; ${humanize(_.pluralize(props.table))}</Link><h1 className='card-title'>${humanize(props.table)} #{props.current ? props.current.rowId : 'New'}</h1>
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
          ${fields.map((key) => {
            return `<div className='form-group row'>
            <label className='col-sm-2 col-form-label'>${humanize(key)}</label>
            <Field className='form-control col-sm-10' name='${_.camelCase(key)}' component='input' type='text' placeholder='${key}' />
            <small className='form-text text-muted offset-sm-2'>tip: ${_.camelCase(key)}</small>
          </div>`
          }).join(`
          `)}
          <div className='form-group row'>
            <div className='offset-sm-2'>
              <button className='btn btn-primary' type='submit' disabled={submitting || pristine}>Submit{submitting ? '...' : null}</button>
              &nbsp;<Link to='/${_.snakeCase(_.pluralize(props.table))}'>Cancel</Link>
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
    <Link to='/${_.snakeCase(_.pluralize(props.table))}'>&larr; ${humanize(_.pluralize(props.table))} </Link><h1 className='card-title'>${humanize(props.table)} #{props.current.rowId}</h1>
    <table>
      <tbody>
        ${fields.map((key) => {
          return `<tr>
        <th>${humanize(key)}</th>
        <td>{props.current.${_.camelCase(key)}}</td>
      </tr>`
        }).join(`
      `)}
      </tbody>
    </table>
    <Link to={\`/${_.snakeCase(_.pluralize(props.table))}/\${props.current.id}/edit\`}><button className='btn btn-secondary'>Edit</button></Link>
  </div>
}

// DeleteTuple is a button (or change it to something else)
const DeleteTuple = (props) => {
  let onClick = () => {
    props.delete${_.upperFirst(_.camelCase(props.table))}ByID({
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
    <Link to='/'>&larr; Home</Link><h1 className='card-title'>${humanize(_.pluralize(props.table))}</h1>
    <div className='float-right'>
      <Link to='/${_.snakeCase(_.pluralize(props.table))}/new'><button className='btn btn-primary'>New ${humanize(props.table)} &hellip;</button></Link>
    </div>
    <table className="table table-hover">
      <thead>
        <tr>
          ${fields.map((key) => {
            return `<th>${humanize(key)}</th>`
          }).join(`
          `)}
          <th></th>
          <th></th>
        </tr>
      </thead>
      <tbody>
        {((props.data.all${_.upperFirst(_.camelCase(_.pluralize(props.table)))} && props.data.all${_.upperFirst(_.camelCase(_.pluralize(props.table)))}.nodes) || []).map(row => {
          return <tr key={row.rowId}>
            ${fields.map((key) => {
              return `<td><Link to={\`/${_.snakeCase(_.pluralize(props.table))}/\${row.id}\`}>{row.${_.camelCase(key)}}</Link></td>`
            }).join(`
            `)}
            <td><Link to={\`/${_.snakeCase(_.pluralize(props.table))}/\${row.id}/edit\`}><button className='btn btn-secondary'>Edit</button></Link></td>
            <td><DeleteTuple id={row.id} {...props} /></td>
          </tr>
        })}
      </tbody>
    </table>
  </div>
}

// seems like \`compose\` cannot deal with 2 gql\`query\`?
// so we're breaking it out
const GetTuple = graphql(gql\`
  query ${_.camelCase(props.table)}($rowid: ID!){
    ${_.camelCase(props.table)}ByID(id: $rowid) {
      id
      rowId
      ${fields.map((key) => {
        return _.camelCase(key)
      }).join(`
      `)}
    }
  }
\`)((props) => {
  if (props.loading || (!props.data.${_.camelCase(props.table)}ByID)) {
    return <p>Loading&hellip;</p>
  }
  return <div>
    {React.Children.map(props.children, (child) => {
      return React.cloneElement(child, {current: props.data.${_.camelCase(props.table)}ByID})
    })}
  </div>
})

const Component = compose(
  graphql(gql\`
    query {
      all${_.upperFirst(_.camelCase(_.pluralize(props.table)))}(pageSize: 30) {
        nodes {
          id
          rowId
          ${fields.map((key) => {
            return _.camelCase(key)
          }).join(`
          `)}
        }
      }
    }
  \`, {name: 'data'}),
  graphql(gql\`
    mutation delete${_.upperFirst(_.camelCase(props.table))}ByID($id: ID!) {
      delete${_.upperFirst(_.camelCase(props.table))}ByID(id:$id) {
        id
        rowId
        ${fields.map((key) => {
          return _.camelCase(key)
        }).join(`
        `)}
      }
    }
  \`, {name: 'delete${_.upperFirst(_.camelCase(props.table))}ByID'}),
  graphql(gql\`
    mutation create${_.upperFirst(_.camelCase(props.table))}($input: Create${_.upperFirst(_.camelCase(props.table))}Input!) {
      create${_.upperFirst(_.camelCase(props.table))}(input: $input) {
        id
        rowId
        ${fields.map((key) => {
          return _.camelCase(key)
        }).join(`
        `)}
      }
    }
  \`, {name: 'create${_.upperFirst(_.camelCase(props.table))}'}),
  graphql(gql\`
    mutation update${_.upperFirst(_.camelCase(props.table))}ByID($id: ID!, $input: Update${_.upperFirst(_.camelCase(props.table))}Input!) {
      update${_.upperFirst(_.camelCase(props.table))}ByID(id: $id, input: $input) {
        id
        rowId
        ${fields.map((key) => {
          return _.camelCase(key)
        }).join(`
        `)}
      }
    }
  \`, {name: 'update${_.upperFirst(_.camelCase(props.table))}ByID'})
)((props) => {
  return <div>
    <Switch>
      <Route exact path='/${_.snakeCase(_.pluralize(props.table))}' render={() => <ListTuples {...props} />} />
      <Route exact path='/${_.snakeCase(_.pluralize(props.table))}/new' render={() => <TupleForm {...props} mutate={props.create${_.upperFirst(_.camelCase(props.table))}} />} />
      <Route path='/${_.snakeCase(_.pluralize(props.table))}/:rowid/edit' render={({ match: { params } }) => {
        return <GetTuple rowid={params.rowid}>
          <TupleForm {...props} params={params} mutate={props.update${_.upperFirst(_.camelCase(props.table))}ByID} />
        </GetTuple>
      }} />
      <Route path='/${_.snakeCase(_.pluralize(props.table))}/:rowid' render={({ match: { params } }) => {
        return <GetTuple rowid={params.rowid}>
          <ShowTuple {...props} params={params} />
        </GetTuple>
      }} />
    </Switch>
  </div>
})

export default Component
`
}

export default Template
