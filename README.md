# MyTube

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix


$ mix phx.gen.context Core Event events title:string medium:string medium_uuid:string


## Question form

<form phx-submit="save" phx-change="change">
  <div class="form-group">
    <label for="formcontent">Content</label>
    <input 
      type="text" 
      class="form-control" 
      id="formcontent" 
      aria-describedby="form content">
    </input>
  </div>
  <button 
    type="submit" 
    class="btn btn-primary"
    phx-disable-with="...Saving">
    Submit
  </button>
</form>
<%= form_for @question_changeset, "#", [phx_change: :change, phx_submit: :save], fn f -> %>
  <%= input(f, :content, using: :textarea, html_opts: [rows: 5, required: true]) %>
  <%= submit "Submit", phx_disable_with: "Saving...", class: "btn btn-primary" %>
<% end %>