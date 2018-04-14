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
    if (props.current) {
      let formId = form.id
      delete form.id
      mutateInput.variables = {
        id: formId,
        input: { ...form }
      }
    }
    props.mutate(mutateInput).then(({ data }) => {
      props.history.push('/comments')
      props.data.refetch()
    }).catch((error) => {
      console.log('there was an error sending the query', error)
    })
    return false
  }

  return <div className='card-body'>
    <Link to='/comments'>&larr; Comments</Link><h1 className='card-title'>Comment #{props.current ? props.current.rowId : 'New'}</h1>
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

// ShowTuple displays a tuple, be creative in your HTML
const ShowTuple = (props) => {
  return <div className='card-body'>
    <Link to='/comments'>&larr; Comments </Link><h1 className='card-title'>Comment #{props.current.rowId}</h1>
    <table>
      <tbody>
        <tr>
          <th>id</th>
          <td>{props.current.id}</td>
        </tr>
        <tr>
          <th>postID</th>
          <td>{props.current.postID}</td>
        </tr>
        <tr>
          <th>author</th>
          <td>{props.current.author}</td>
        </tr>
        <tr>
          <th>body</th>
          <td>{props.current.body}</td>
        </tr>
        <tr>
          <th>notes</th>
          <td>{props.current.notes}</td>
        </tr>
        <tr>
          <th>createdAt</th>
          <td>{props.current.createdAt}</td>
        </tr>
        <tr>
          <th>updatedAt</th>
          <td>{props.current.updatedAt}</td>
        </tr>
      </tbody>
    </table>
    <Link to={`/comments/${props.current.id}/edit`}><button className='btn btn-secondary'>Edit</button></Link>
  </div>
}

// DeleteTuple is a button (or change it to something else)
const DeleteTuple = (props) => {
  let onClick = () => {
    props.deleteCommentByID({
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
        {((props.data.allComments && props.data.allComments.nodes) || []).map(row => {
          return <tr key={row.rowId}>
            <td><Link to={`/comments/${row.id}`}>{row.id}</Link></td>
            <td><Link to={`/comments/${row.id}`}>{row.postID}</Link></td>
            <td><Link to={`/comments/${row.id}`}>{row.author}</Link></td>
            <td><Link to={`/comments/${row.id}`}>{row.body}</Link></td>
            <td><Link to={`/comments/${row.id}`}>{row.notes}</Link></td>
            <td><Link to={`/comments/${row.id}`}>{row.createdAt}</Link></td>
            <td><Link to={`/comments/${row.id}`}>{row.updatedAt}</Link></td>
            <td><Link to={`/comments/${row.id}/edit`}><button className='btn btn-secondary'>Edit</button></Link></td>
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
  query comment($rowid: ID!){
    commentByID(id: $rowid) {
      id
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
`)((props) => {
  if (props.loading || (!props.data.commentByID)) {
    return <p>Loading&hellip;</p>
  }
  return <div>
    {React.Children.map(props.children, (child) => {
      return React.cloneElement(child, {current: props.data.commentByID})
    })}
  </div>
})

const Component = compose(
  graphql(gql`
    query {
      allComments(pageSize: 30) {
        nodes {
          id
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
  `, {name: 'data'}),
  graphql(gql`
    mutation deleteCommentByID($id: ID!) {
      deleteCommentByID(id:$id) {
        id
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
  `, {name: 'deleteCommentByID'}),
  graphql(gql`
    mutation createComment($input: CreateCommentInput!) {
      createComment(input: $input) {
        id
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
  `, {name: 'createComment'}),
  graphql(gql`
    mutation updateCommentByID($id: ID!, $input: UpdateCommentInput!) {
      updateCommentByID(id: $id, input: $input) {
        id
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
  `, {name: 'updateCommentByID'})
)((props) => {
  return <div>
    <Switch>
      <Route exact path='/comments' render={() => <ListTuples {...props} />} />
      <Route exact path='/comments/new' render={() => <TupleForm {...props} mutate={props.createComment} />} />
      <Route path='/comments/:rowid/edit' render={({ match: { params } }) => {
        return <GetTuple rowid={params.rowid}>
          <TupleForm {...props} params={params} mutate={props.updateCommentByID} />
        </GetTuple>
      }} />
      <Route path='/comments/:rowid' render={({ match: { params } }) => {
        return <GetTuple rowid={params.rowid}>
          <ShowTuple {...props} params={params} />
        </GetTuple>
      }} />
    </Switch>
  </div>
})

export default Component
