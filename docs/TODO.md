# Cleanup tasks

- [ ] (bitbender-8): Replace model types with types inferred from zod schemas.
- [ ] (bitbender-8): Add a route to serve files. Make sure to create openapi docs for it.
- [ ] (bitbender-8): The when document urls are stored, they probably need to have the domain appended to them so that they can be served properly.
- [ ] (bitbender-8): Consider adding a page that shows a list of recipients or at A SEARCH CAMPAIGN BY RECIPIENT FEATURE.
- DOC-UPDATE: Update diagrams marked with `[update at end]` at the testing phase.

## Things to discuss

- Consider overhauling the way you handle documents. Each document should have a name or an id or some descriptive fields. Especially the relationships between redacted and unredacted documents must be ironed out.
- Recipients have no way of updating the title and description, and other fields not listed explicitly in requests right now.
- Auth0 offers phone based passwordless auth0, it does not let you use phone numbers as a substitute for emails. we may not want this approch so, because of billing costs and other reasons.

## Things to consider adding

- How to better support modifying payment information
