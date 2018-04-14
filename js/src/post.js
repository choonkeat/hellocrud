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
      props.history.push('/posts')
      props.data.refetch()
    }).catch((error) => {
      console.log('there was an error sending the query', error)
    })
    return false
  }

  return <div className='card-body'>
    <Link to='/posts'>&larr; Posts</Link><h1 className='card-title'>Post #{props.current ? props.current.rowId : 'New'}</h1>
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
            <label className='col-sm-2 col-form-label'>title</label>
            <Field className='form-control col-sm-10' name='title' component='input' type='text' placeholder='title' />
            <small className='form-text text-muted offset-sm-2'>tip: title</small>
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
              &nbsp;<Link to='/posts'>Cancel</Link>
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
    <Link to='/posts'>&larr; Posts </Link><h1 className='card-title'>Post #{props.current.rowId}</h1>
    <table>
      <tbody>
        <tr>
          <th>id</th>
          <td>{props.current.id}</td>
        </tr>
        <tr>
          <th>title</th>
          <td>{props.current.title}</td>
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
    <Link to={`/posts/${props.current.id}/edit`}><button className='btn btn-secondary'>Edit</button></Link>
  </div>
}

// DeleteTuple is a button (or change it to something else)
const DeleteTuple = (props) => {
  let onClick = () => {
    props.deletePostByID({
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
    <Link to='/'>&larr; Home</Link><h1 className='card-title'>Posts</h1>
    <div className='float-right'>
      <Link to='/posts/new'><button className='btn btn-primary'>New Post &hellip;</button></Link>
    </div>
    <table className='table table-hover'>
      <thead>
        <tr>
          <th>id</th>
          <th>title</th>
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
        {((props.data.allPosts && props.data.allPosts.nodes) || []).map(row => {
          return <tr key={row.rowId}>
            <td><Link to={`/posts/${row.id}`}>{row.id}</Link></td>
            <td><Link to={`/posts/${row.id}`}>{row.title}</Link></td>
            <td><Link to={`/posts/${row.id}`}>{row.author}</Link></td>
            <td><Link to={`/posts/${row.id}`}>{row.body}</Link></td>
            <td><Link to={`/posts/${row.id}`}>{row.notes}</Link></td>
            <td><Link to={`/posts/${row.id}`}>{row.createdAt}</Link></td>
            <td><Link to={`/posts/${row.id}`}>{row.updatedAt}</Link></td>
            <td><Link to={`/posts/${row.id}/edit`}><button className='btn btn-secondary'>Edit</button></Link></td>
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
  query post($rowid: ID!){
    postByID(id: $rowid) {
      id
      rowId
      id
      title
      author
      body
      notes
      createdAt
      updatedAt
    }
  }
`)((props) => {
  if (props.loading || (!props.data.postByID)) {
    return <p>Loading&hellip;</p>
  }
  return <div>
    {React.Children.map(props.children, (child) => {
      return React.cloneElement(child, {current: props.data.postByID})
    })}
  </div>
})

const Component = compose(
  graphql(gql`
    query {
      allPosts(pageSize: 30) {
        nodes {
          id
          rowId
          id
          title
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
    mutation deletePostByID($id: ID!) {
      deletePostByID(id:$id) {
        id
        rowId
        id
        title
        author
        body
        notes
        createdAt
        updatedAt
      }
    }
  `, {name: 'deletePostByID'}),
  graphql(gql`
    mutation createPost($input: CreatePostInput!) {
      createPost(input: $input) {
        id
        rowId
        id
        title
        author
        body
        notes
        createdAt
        updatedAt
      }
    }
  `, {name: 'createPost'}),
  graphql(gql`
    mutation updatePostByID($id: ID!, $input: UpdatePostInput!) {
      updatePostByID(id: $id, input: $input) {
        id
        rowId
        id
        title
        author
        body
        notes
        createdAt
        updatedAt
      }
    }
  `, {name: 'updatePostByID'})
)((props) => {
  return <div>
    <Switch>
      <Route exact path='/posts' render={() => <ListTuples {...props} />} />
      <Route exact path='/posts/new' render={() => <TupleForm {...props} mutate={props.createPost} />} />
      <Route path='/posts/:rowid/edit' render={({ match: { params } }) => {
        return <GetTuple rowid={params.rowid}>
          <TupleForm {...props} params={params} mutate={props.updatePostByID} />
        </GetTuple>
      }} />
      <Route path='/posts/:rowid' render={({ match: { params } }) => {
        return <GetTuple rowid={params.rowid}>
          <ShowTuple {...props} params={params} />
        </GetTuple>
      }} />
    </Switch>
  </div>
})

export default Component
