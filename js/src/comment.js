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
      if (this.props.searchCommentsData && this.props.searchCommentsData.refetch) this.props.searchCommentsData.refetch()
      this.props.history.push('/comments')
    }).catch((error) => {
      setState({ errors: [error] })
    })
    return false
  }

  render () {
    let state = this.state
    let current = this.props.current

    return <div className='card-body'>
      <Link to='/comments'>&larr; Comments</Link><h1 className='card-title'>{current && current.id ? 'Edit' : 'New'} Comment</h1>
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
            <div className='form-group row'>
              <label className='col-sm-2 col-form-label'>postID</label>
              <Field className='form-control col-sm-10' name='postID' component='input' type='text' placeholder='post_id' />
              <small className='form-text text-muted offset-sm-2'>tip: postID</small>
            </div>
            <div className='form-group row'>
              <label className='col-sm-2 col-form-label'>author</label>
              <Field className='form-control col-sm-10' name='author' component='input' type='text' placeholder='author' />
              <small className='form-text text-muted offset-sm-2'>tip: author</small>
            </div>
            <div className='form-group row'>
              <label className='col-sm-2 col-form-label'>body</label>
              <Field className='form-control col-sm-10' name='body' component='input' type='text' placeholder='body' />
              <small className='form-text text-muted offset-sm-2'>tip: body</small>
            </div>
            <div className='form-group row'>
              <label className='col-sm-2 col-form-label'>notes</label>
              <Field className='form-control col-sm-10' name='notes' component='input' type='text' placeholder='notes' />
              <small className='form-text text-muted offset-sm-2'>tip: notes</small>
            </div>
            <div className='form-group row'>
              <div className='offset-sm-2'>
                <button className='btn btn-primary' type='submit' disabled={submitting || pristine}>Submit{submitting ? '...' : null}</button>
                &nbsp;<Link to='/comments'>Cancel</Link>
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
    <Link to='/comments'>&larr; Comments </Link><h1 className='card-title'>Comment #{current.rowId}</h1>
    <table>
      <tbody>
        <tr>
          <th>id</th>
          <td>{current.id}</td>
        </tr>
        <tr>
          <th>postID</th>
          <td>{current.postID}</td>
        </tr>
        <tr>
          <th>author</th>
          <td>{current.author}</td>
        </tr>
        <tr>
          <th>body</th>
          <td>{current.body}</td>
        </tr>
        <tr>
          <th>notes</th>
          <td>{current.notes}</td>
        </tr>
        <tr>
          <th>createdAt</th>
          <td>{current.createdAt}</td>
        </tr>
        <tr>
          <th>updatedAt</th>
          <td>{current.updatedAt}</td>
        </tr>
      </tbody>
    </table>
    <Link to={`/comments/${current.id}/edit`}><button className='btn btn-secondary'>Edit</button></Link>
  </div>
}

// DeleteTuple is a button (or change it to something else)
export const DeleteTuple = graphql(gql`
  mutation deleteCommentByID($id: ID!) {
    deleteCommentByID(id:$id) {
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
`, {name: 'deleteCommentByID'})(({ id, deleteCommentByID, searchCommentsData }) => {
  let onClick = () => {
    deleteCommentByID({
      variables: {
        id: id
      }
    }).then((...args) => {
      if (searchCommentsData && searchCommentsData.refetch) searchCommentsData.refetch()
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

export const ListTuples = ({searchCommentsData}) => {
  return <div className='card-body'>
    <Link to='/'>&larr; Home</Link><h1 className='card-title'>Comments</h1>
    <div className='float-right'>
      <Link to='/comments/new'><button className='btn btn-primary'>New Comment &hellip;</button></Link>
    </div>
    <table className='table table-hover'>
      <thead>
        <tr>
          <th>id</th>
          <th>postID</th>
          <th>author</th>
          <th>body</th>
          <th>notes</th>
          <th>createdAt</th>
          <th>updatedAt</th>
          <th />
          <th />
        </tr>
      </thead>
      <tbody>
        {((searchCommentsData.searchComments && searchCommentsData.searchComments.nodes) || []).map(row => {
          return <tr key={row.rowId}>
            <td><Link to={`/comments/${row.id}`}>{row.id}</Link></td>
            <td><Link to={`/comments/${row.id}`}>{row.postID}</Link></td>
            <td><Link to={`/comments/${row.id}`}>{row.author}</Link></td>
            <td><Link to={`/comments/${row.id}`}>{row.body}</Link></td>
            <td><Link to={`/comments/${row.id}`}>{row.notes}</Link></td>
            <td><Link to={`/comments/${row.id}`}>{row.createdAt}</Link></td>
            <td><Link to={`/comments/${row.id}`}>{row.updatedAt}</Link></td>
            <td><Link to={`/comments/${row.id}/edit`}><button className='btn btn-secondary'>Edit</button></Link></td>
            <td><DeleteTuple id={row.id} searchCommentsData={searchCommentsData} /></td>
          </tr>
        })}
      </tbody>
    </table>
  </div>
}

// seems like `compose` cannot deal with 2 gql`query`?
// so we're breaking it out
export const GetTuple = graphql(gql`
  query comment($rowid: ID!){
    commentByID(id: $rowid) {
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
`)(({ loading, data, children }) => {
  if (loading || (!data.commentByID)) {
    return <p>Loading&hellip;</p>
  }
  return <div>
    {React.Children.map(children, (child) => {
      return React.cloneElement(child, {current: data.commentByID})
    })}
  </div>
})

export const Create = graphql(gql`
  mutation createComment($input: CreateCommentInput!) {
    createComment(input: $input) {
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
`, {name: 'createComment'})(({current, history, searchCommentsData, createComment}) => {
  return <TupleForm current={current} history={history} searchCommentsData={searchCommentsData} mutate={createComment} />
})

export const Edit = graphql(gql`
  mutation updateCommentByID($id: ID!, $input: UpdateCommentInput!) {
    updateCommentByID(id: $id, input: $input) {
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
`, {name: 'updateCommentByID'})(({current, history, searchCommentsData, updateCommentByID}) => {
  return <TupleForm current={current} history={history} searchCommentsData={searchCommentsData} mutate={updateCommentByID} />
})

export const Crud = graphql(gql`
  query searchComments($search: SearchCommentInput){
    searchComments(pageSize: 30, input: $search) {
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
`, {name: 'searchCommentsData'})(({search, history, searchCommentsData}) => {
  return <div>
    <Switch>
      <Route exact path='/comments' render={() => <ListTuples history={history} searchCommentsData={searchCommentsData} search={search} />} />
      <Route exact path='/comments/new' render={() => <Create history={history} searchCommentsData={searchCommentsData} />} />
      <Route path='/comments/:rowid/edit' render={({ match: { params } }) => {
        return <GetTuple rowid={params.rowid}><Edit history={history} params={params} /></GetTuple>
      }} />
      <Route path='/comments/:rowid' render={({ match: { params } }) => {
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
    query searchComments($search: SearchCommentInput){
      searchComments(pageSize: 30, input: $search) {
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
  `, {name: 'searchCommentsData'})(props => <ListTuples {...props} />),
  Create: Create,
  Edit: Edit
}

export default Component
