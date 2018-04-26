// Code generated by SQLBoiler (https://github.com/volatiletech/sqlboiler). DO NOT EDIT.
// This file is meant to be re-generated in place and/or deleted at any time.

package graph

import (
	"context"
	"encoding/json"
	"fmt"
	"reflect"
	"strconv"

	"github.com/choonkeat/hellocrud/golang/example/dbmodel"
	graphql "github.com/graph-gophers/graphql-go"
	"github.com/pkg/errors"
	"github.com/volatiletech/sqlboiler/boil"
	"github.com/volatiletech/sqlboiler/queries/qm"
)

// SchemaTypeComment is the GraphQL schema type for Comment
var SchemaTypeComment = `
# Comment is a resource type
type Comment {
	
		# Convenient GUID for ReactJS component @key attribute
		rowId: String!
		id: ID!
		postID: Int!
		author: String!
		body: String!
		notes: String
		createdAt: Time
		updatedAt: Time
		# post has a foreign key pointing to Comment
		post: Post
}

type CommentsCollection {
	nodes: [Comment!]!
}
`

// NewComment returns a new Comment instance
func NewComment(db boil.Executor, model dbmodel.Comment) Comment {
	return Comment{
		model: model,
		db:    db,
	}
}

// NewCommentsCollection returns a new CommentsCollection instance
func NewCommentsCollection(nodes []Comment) CommentsCollection {
	return CommentsCollection{
		nodes: nodes,
	}
}

// Comment is an object to back GraphQL type
type Comment struct {
	model dbmodel.Comment
	db    boil.Executor
}

// GraphQL friendly getters

// RowID is the Comment GUID
func (o Comment) RowID() string {
	return fmt.Sprintf("Comment%d", o.model.ID) // int
}

// ID is the Comment id
func (o Comment) ID() graphql.ID {
	return graphql.ID(fmt.Sprintf("%d", o.model.ID)) // int
}

// PostID is the Comment post_id
func (o Comment) PostID() int32 {
	return int32(o.model.PostID) // int
}

// Author is the Comment author
func (o Comment) Author() string {
	return o.model.Author // string
}

// Body is the Comment body
func (o Comment) Body() string {
	return o.model.Body // string
}

// Notes is the Comment notes
func (o Comment) Notes() *string {
	return o.model.Notes.Ptr() // null.String
}

// CreatedAt is the Comment created_at
func (o Comment) CreatedAt() *graphql.Time {
	if o.model.CreatedAt.Valid {
		return &graphql.Time{Time: o.model.CreatedAt.Time}
	}
	return nil // null.Time
}

// UpdatedAt is the Comment updated_at
func (o Comment) UpdatedAt() *graphql.Time {
	if o.model.UpdatedAt.Valid {
		return &graphql.Time{Time: o.model.UpdatedAt.Time}
	}
	return nil // null.Time
}

// Post pointed to by the foreign key
func (o Comment) Post() *Post {
	if o.model.R == nil || o.model.R.Post == nil {
		return nil
	}
	return &Post{
		model: *o.model.R.Post,
		db:    o.db,
	}
}

// CommentsCollection is the struct representing a collection of GraphQL types
type CommentsCollection struct {
	nodes []Comment
	// future meta data goes here, e.g. count
}

// Nodes returns the list of GraphQL types
func (c CommentsCollection) Nodes(ctx context.Context) []Comment {
	return c.nodes
}

// SchemaCreateCommentInput is the schema create input for Comment
var SchemaCreateCommentInput = `
# CreateCommentInput is a create input type for Comment resource
input CreateCommentInput {
	
	  postID: Int!
	  author: String!
	  body: String!
	  notes: String
}
`

// createCommentInput is an object to back Comment mutation (create) input type
type createCommentInput struct {
	PostID int32   `json:"post_id"`
	Author string  `json:"author"`
	Body   string  `json:"body"`
	Notes  *string `json:"notes"`
}

// SchemaUpdateCommentInput is the schema update input for Comment
var SchemaUpdateCommentInput = `
input UpdateCommentInput {
	
	  postID: Int!
	  author: String!
	  body: String!
	  notes: String
}
`

// updateCommentInput is an object to back Comment mutation (update) input type
type updateCommentInput struct {
	PostID int32   `json:"post_id"`
	Author string  `json:"author"`
	Body   string  `json:"body"`
	Notes  *string `json:"notes"`
}

// searchCommentArgs is an object to back Comment search arguments type
type searchCommentArgs struct {
	PostID    *int32        `json:"post_id"`
	Author    *string       `json:"author"`
	Body      *string       `json:"body"`
	Notes     *string       `json:"notes"`
	CreatedAt *graphql.Time `json:"created_at"`
	UpdatedAt *graphql.Time `json:"updated_at"`
}

// QueryMods returns a list of QueryMod based on the struct values
func (s *searchCommentArgs) QueryMods() []qm.QueryMod {
	mods := []qm.QueryMod{}
	// Get reflect value
	v := reflect.ValueOf(s).Elem()
	// Iterate struct fields
	for i := 0; i < v.NumField(); i++ {
		field := v.Type().Field(i) // StructField
		value := v.Field(i)        // Value
		if value.IsNil() || !value.IsValid() {
			// Skip if field is nil
			continue
		}

		// Get column name from tags
		column, hasColumnName := field.Tag.Lookup("json")
		// Skip if no DB definition
		if !hasColumnName {
			continue
		}

		operator := "="
		val := value.Elem().Interface()
		if dataType := field.Type.String(); (dataType == "string" || dataType == "*string") &&
			val.(string) != "" {
			operator = "LIKE"
			val = fmt.Sprintf("%%%s%%", val)
		}
		mods = append(mods, qm.And(fmt.Sprintf("%s %s ?", column, operator), val))
	}
	return mods
}

// SchemaSearchCommentInput is the schema search input for Comment
var SchemaSearchCommentInput = `
# SearchCommentInput is a search input/arguments type for Comment resources
input SearchCommentInput {
	
	  postID: Int
	  author: String
	  body: String
	  notes: String
}
`

// searchCommentInput is an object to back Comment search arguments input type
type searchCommentInput struct {
	PostID    *int32        `json:"post_id"`
	Author    *string       `json:"author"`
	Body      *string       `json:"body"`
	Notes     *string       `json:"notes"`
	CreatedAt *graphql.Time `json:"created_at"`
	UpdatedAt *graphql.Time `json:"updated_at"`
}

// QueryMods returns a list of QueryMod based on the struct values
func (s *searchCommentInput) QueryMods() []qm.QueryMod {
	mods := []qm.QueryMod{}
	// Get reflect value
	v := reflect.ValueOf(s).Elem()
	// Iterate struct fields
	for i := 0; i < v.NumField(); i++ {
		field := v.Type().Field(i) // StructField
		value := v.Field(i)        // Value
		if value.IsNil() || !value.IsValid() {
			// Skip if field is nil
			continue
		}

		// Get column name from tags
		column, hasColumnName := field.Tag.Lookup("json")
		// Skip if no DB definition
		if !hasColumnName {
			continue
		}

		operator := "="
		val := value.Elem().Interface()
		if dataType := field.Type.String(); (dataType == "string" || dataType == "*string") &&
			val.(string) != "" {
			operator = "LIKE"
			val = fmt.Sprintf("%%%s%%", val)
		}
		mods = append(mods, qm.And(fmt.Sprintf("%s %s ?", column, operator), val))
	}
	return mods
}

// AllComments retrieves Comments based on the provided search parameters
func (r *Resolver) AllComments(ctx context.Context, args struct {
	Since    *graphql.ID
	PageSize *int
	Search   *searchCommentInput
}) (CommentsCollection, error) {
	result := CommentsCollection{}

	mods := []qm.QueryMod{
		queryModPageSize(args.PageSize),

		// TODO: Add eager loading based on requested fields
		qm.Load("Post"),
	}

	if args.Since != nil {
		s := string(*args.Since)
		i, err := strconv.ParseInt(s, 10, 64)
		if err != nil {
			return result, err
		}
		mods = append(mods, qm.Offset(int(i)))
	}
	if args.Search != nil {
		mods = append(mods, args.Search.QueryMods()...)
	}
	slice, err := dbmodel.Comments(r.db, mods...).All()
	if err != nil {
		return result, errors.Wrapf(err, "allComments(%#v)", args)
	}
	for _, m := range slice {
		result.nodes = append(result.nodes, Comment{model: *m, db: r.db})
	}

	return result, nil
}

// CommentByID retrieves Comment by ID
func (r *Resolver) CommentByID(ctx context.Context, args struct {
	ID graphql.ID
}) (Comment, error) {
	result := Comment{}
	i, err := strconv.ParseInt(string(args.ID), 10, 64)
	if err != nil {
		return result, errors.Wrapf(err, "CommentByID(%#v)", args)
	}
	id := int(i)

	mods := []qm.QueryMod{
		qm.Where("id = ?", id),
		// TODO: Add eager loading based on requested fields
		qm.Load("Post")}

	m, err := dbmodel.Comments(r.db, mods...).One()
	if err != nil {
		return result, errors.Wrapf(err, "CommentByID(%#v)", args)
	} else if m == nil {
		return result, errors.New("not found")
	}
	return Comment{model: *m, db: r.db}, nil
}

// CreateComment creates a Comment based on the provided input
func (r *Resolver) CreateComment(ctx context.Context, args struct {
	Input createCommentInput
}) (Comment, error) {
	result := Comment{}
	m := dbmodel.Comment{}
	data, err := json.Marshal(args.Input)
	if err != nil {
		return result, errors.Wrapf(err, "json.Marshal(%#v)", args.Input)
	}
	if err = json.Unmarshal(data, &m); err != nil {
		return result, errors.Wrapf(err, "json.Unmarshal(%s)", data)
	}

	if err := m.Insert(r.db); err != nil {
		return result, errors.Wrapf(err, "createComment(%#v)", m)
	}
	return Comment{model: m, db: r.db}, nil
}

// UpdateCommentByID updates a Comment based on the provided ID and input
func (r *Resolver) UpdateCommentByID(ctx context.Context, args struct {
	ID    graphql.ID
	Input updateCommentInput
}) (Comment, error) {
	result := Comment{}
	i, err := strconv.ParseInt(string(args.ID), 10, 64)
	if err != nil {
		return result, errors.Wrapf(err, "CommentByID(%#v)", args)
	}
	id := int(i)

	m, err := dbmodel.FindComment(r.db, id)
	if err != nil {
		return result, errors.Wrapf(err, "updateCommentByID(%#v)", args)
	} else if m == nil {
		return result, errors.New("not found")
	}
	data, err := json.Marshal(args.Input)
	if err != nil {
		return result, errors.Wrapf(err, "json.Marshal(%#v)", args.Input)
	}
	if err = json.Unmarshal(data, &m); err != nil {
		return result, errors.Wrapf(err, "json.Unmarshal(%s)", data)
	}

	if err := m.Update(r.db); err != nil {
		return result, errors.Wrapf(err, "updateComment(%#v)", m)
	}
	return Comment{model: *m, db: r.db}, nil
}

// DeleteCommentByID deletes a Comment based on the provided ID
func (r *Resolver) DeleteCommentByID(ctx context.Context, args struct {
	ID graphql.ID
}) (Comment, error) {
	result := Comment{}
	i, err := strconv.ParseInt(string(args.ID), 10, 64)
	if err != nil {
		return result, errors.Wrapf(err, "CommentByID(%#v)", args)
	}
	id := int(i)

	m, err := dbmodel.FindComment(r.db, id)
	if err != nil {
		return result, errors.Wrapf(err, "updateCommentByID(%#v)", args)
	} else if m == nil {
		return result, errors.New("not found")
	}
	if err := m.Delete(r.db); err != nil {
		return result, errors.Wrapf(err, "deleteCommentByID(%#v)", m)
	}
	return Comment{model: *m, db: r.db}, nil
}
