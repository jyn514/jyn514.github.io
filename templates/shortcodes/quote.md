<figure>
<blockquote cite="{{ url }}">

  {{ body }}

</blockquote>
<figcaption>
<cite {% if username %}class=username{% endif %}><a href="{{ url }}">{{ author | markdown(inline=true) }}</a></cite>
</figcaption>
</figure>
