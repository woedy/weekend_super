describe('Order lifecycle smoke test', () => {
  const backend = () => Cypress.env('BACKEND_BASE_URL');

  it('creates and completes an order through the QA smoke endpoint', () => {
    cy.request('POST', `${backend()}/api/qa/order-smoke/`).then((response) => {
      expect(response.status).to.eq(200);
      const body = response.body;
      expect(body.status).to.eq('completed');
      expect(body.order_id).to.match(/^WC/);
      expect(body.ledger).to.have.length(3);
      const types = body.ledger.map((entry) => entry.entry_type);
      expect(types).to.include.members(['grocery_advance', 'platform_fee', 'final_payout']);
      expect(Number(body.totals.total_price)).to.be.greaterThan(0);
      expect(body.timeline[0].status).to.eq('completed');
    });
  });
});
