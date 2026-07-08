# Phase 23 — Checkout Customer Information UI Cleanup

**Data:** 8 korrik 2026  
**Qëllimi:** Pastro shfaqjen e card-it të parë në Checkout (klient + adresë), pa prekur logjikën e placeOrder.

---

## Root cause (UI)

Card-i shfaqte `label` të adresës si **"Emri: Home"** dhe **Marrësi:** për `fullName`, me email në krye të card-it. Label është për Address Selector, jo për summary.

---

## UI e re (`_UserInfoCard`)

```
{fullName}                    ← recipient / customer name (jo label)
Email: {email}

──────── divider ────────

Adresa e dorëzimit            Ndrysho >
Adresa: …
Qyteti: …
Shteti: …
Telefoni: …                   (vetëm nëse jo bosh)
Kodi postar: …                (vetëm nëse jo bosh)
```

**Hequr:** `Emri: Home`, `Marrësi:`, email “jashtë” strukturës së re, fusha bosh/`null`.

**I paprekur:** CheckoutController, repositories, placeOrder, payload, routing, payment, Address Selector.

---

## Rezultatet

### flutter analyze
```
No issues found!
```

### flutter test
```
All tests passed!
```

---

## Rezultati final

Checkout summary card shfaq emrin + email në krye, pastaj adresën pa label “Home” dhe pa “Marrësi”. Logjika e placeOrder është e paprekur.
