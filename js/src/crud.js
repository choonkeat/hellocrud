import React from 'react'
import { introspectionQuery } from 'graphql/utilities'
import { graphql } from 'react-apollo'
import gql from 'graphql-tag'
import { Form, Field } from 'react-final-form'
import Template from './template'

const camelToUnderscore = (s) => {
  return s.split(/(?=[A-Z])/).join('_').toLowerCase()
}

const getTablesFromIntrospection = (types) => {
  let tables = []

  types.forEach((row) => {
    if (row.possibleTypes || !row.fields || row.name.startsWith('__')) return
    tables.push({
      name: row.name,
      fields: row.fields.map((field) => {
        return field.name || camelToUnderscore(field.name)
      })
    })
  })

  return tables
}

class Component extends React.Component {
  constructor (props) {
    super(props)
    this.state = { fields: [] }
    this.onTableChange = this.onTableChange.bind(this)
  }

  onTableChange (event) {
    this.setState({ ...this.state, table: event.target.value })
  }

  render () {
    let onSubmit = console.log
    let result = getTablesFromIntrospection(this.props.data.__schema ? this.props.data.__schema.types : [])
    let fields = []
    result.forEach(row => {
      if (!this.state || row.name !== this.state.table) return
      fields = row.fields
    })

    return <div>
      <h1>Generate a CRUD</h1>
      <Form
        onSubmit={onSubmit}
        initialValues={this.state}
        render={({ handleSubmit, reset, submitting, pristine, values }) => (
          <form onSubmit={handleSubmit}>
            <div className='form-group row'>
              <label className='col-sm-2 col-form-label'>Table</label>
              <Field className='form-control col-sm-10' name='table' component='select' onChange={this.onTableChange}>
                <option />
                {result.map((table, index) => {
                  return <option key={`table_name_${index}`} value={table.name}>{table.name}</option>
                })}
              </Field>
            </div>
            {values.table ? (<div className='form-group row'>
              <label className='col-sm-2 col-form-label'>Columns</label>
              <div className='form-control col-sm-10'>
                {fields.map((field, index) => {
                  return <div key={`field_${index}`}>
                    <label>
                      <Field name='fields' component='input' type='checkbox' key={`table_column_${index}`} value={field} /> {field}
                    </label>
                  </div>
                })}
              </div>
            </div>) : null}

            {values.table ? (<div className='card'>
              <pre className='card-body'>
                <Template {...values} />
              </pre>
            </div>) : null}
          </form>
        )} />
    </div>
  }
}

const ComponentWithData = graphql(gql(introspectionQuery))(Component)

export default ComponentWithData
