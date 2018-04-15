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
      if (this.props.allPostsData && this.props.allPostsData.refetch) this.props.allPostsData.refetch()
      this.props.history.push('/posts')
    }).catch((error) => {
      setState({ errors: [error] })
    })
    return false
  }

  render () {
    let state = this.state
    let current = this.props.current

    return <div className='card-body'>
      <Link to='/posts'>&larr; Posts</Link><h1 className='card-title'>{current && current.id ? 'Edit' : 'New'} Post</h1>
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
}

// ShowTuple displays a tuple, be creative in your HTML
export const ShowTuple = ({ current }) => {
  return <div className='card-body'>
    <Link to='/posts'>&larr; Posts </Link><h1 className='card-title'>Post #{current.rowId}</h1>
    <table>
      <tbody>
        <tr>
          <th>id</th>
          <td>{current.id}</td>
        </tr>
        <tr>
          <th>title</th>
          <td>{current.title}</td>
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
    <Link to={`/posts/${current.id}/edit`}><button className='btn btn-secondary'>Edit</button></Link>
  </div>
}

// DeleteTuple is a button (or change it to something else)
export const DeleteTuple = graphql(gql`
  mutation deletePostByID($id: ID!) {
    deletePostByID(id:$id) {
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
`, {name: 'deletePostByID'})(({ id, deletePostByID, allPostsData }) => {
  let onClick = () => {
    deletePostByID({
      variables: {
        id: id
      }
    }).then((...args) => {
      if (allPostsData && allPostsData.refetch) allPostsData.refetch()
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

export const ListTuples = ({allPostsData}) => {
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
        {((allPostsData.allPosts && allPostsData.allPosts.nodes) || []).map(row => {
          return <tr key={row.rowId}>
            <td><Link to={`/posts/${row.id}`}>{row.id}</Link></td>
            <td><Link to={`/posts/${row.id}`}>{row.title}</Link></td>
            <td><Link to={`/posts/${row.id}`}>{row.author}</Link></td>
            <td><Link to={`/posts/${row.id}`}>{row.body}</Link></td>
            <td><Link to={`/posts/${row.id}`}>{row.notes}</Link></td>
            <td><Link to={`/posts/${row.id}`}>{row.createdAt}</Link></td>
            <td><Link to={`/posts/${row.id}`}>{row.updatedAt}</Link></td>
            <td><Link to={`/posts/${row.id}/edit`}><button className='btn btn-secondary'>Edit</button></Link></td>
            <td><DeleteTuple id={row.id} allPostsData={allPostsData} /></td>
          </tr>
        })}
      </tbody>
    </table>
  </div>
}

// seems like `compose` cannot deal with 2 gql`query`?
// so we're breaking it out
export const GetTuple = graphql(gql`
  query post($rowid: ID!){
    postByID(id: $rowid) {
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
`)(({ loading, data, children }) => {
  if (loading || (!data.postByID)) {
    return <p>Loading&hellip;</p>
  }
  return <div>
    {React.Children.map(children, (child) => {
      return React.cloneElement(child, {current: data.postByID})
    })}
  </div>
})

export const Create = graphql(gql`
  mutation createPost($input: CreatePostInput!) {
    createPost(input: $input) {
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
`, {name: 'createPost'})(({current, history, allPostsData, createPost}) => {
  return <TupleForm current={current} history={history} allPostsData={allPostsData} mutate={createPost} />
})

export const Edit = graphql(gql`
  mutation updatePostByID($id: ID!, $input: UpdatePostInput!) {
    updatePostByID(id: $id, input: $input) {
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
`, {name: 'updatePostByID'})(({current, history, allPostsData, updatePostByID}) => {
  return <TupleForm current={current} history={history} allPostsData={allPostsData} mutate={updatePostByID} />
})

export const Crud = graphql(gql`
  query allPosts($search: SearchPostArgs){
    allPosts(pageSize: 30, search: $search) {
      nodes {
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
`, {name: 'allPostsData'})(({search, history, allPostsData}) => {
  return <div>
    <Switch>
      <Route exact path='/posts' render={() => <ListTuples history={history} allPostsData={allPostsData} search={search} />} />
      <Route exact path='/posts/new' render={() => <Create history={history} allPostsData={allPostsData} />} />
      <Route path='/posts/:rowid/edit' render={({ match: { params } }) => {
        return <GetTuple rowid={params.rowid}><Edit history={history} params={params} /></GetTuple>
      }} />
      <Route path='/posts/:rowid' render={({ match: { params } }) => {
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
    query allPosts($search: SearchPostArgs){
      allPosts(pageSize: 30, search: $search) {
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
  `, {name: 'allPostsData'})(props => <ListTuples {...props} />),
  Create: Create,
  Edit: Edit
}

export default Component
