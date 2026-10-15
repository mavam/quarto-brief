// Maps Quarto metadata to the `brief` function. Values are wrapped in
// `[#{}...]` so that text such as "15. Oktober" does not start a Typst list.
#show: doc => brief(
$if(lang)$
  lang: "$lang$",
$endif$
$if(region)$
  region: "$region$",
$endif$
$if(mainfont)$
  font: ("$mainfont$",),
$elseif(brand.typography.base.family)$
  font: $brand.typography.base.family$,
$endif$
$if(fontsize)$
  fontsize: $fontsize$,
$endif$
$if(text_color)$
  text-color: [#{}$text_color$],
$endif$
$if(muted_color)$
  muted-color: [#{}$muted_color$],
$endif$
$if(reference_label_font)$
  reference-label-font: ("$reference_label_font$",),
$endif$
$if(reference_label_size)$
  reference-label-size: $reference_label_size$,
$endif$
$for(by-author/first)$
  sender: (
$if(it.name.literal)$
    name: [#{}$it.name.literal$],
$endif$
$if(it.phone)$
    phone: [#{}$it.phone$],
$endif$
$if(it.email)$
    email: [#{}$it.email$],
$endif$
$if(it.url)$
    url: [#{}$it.url$],
$endif$
$for(it.affiliations/first)$
$if(it.address)$
    street: [#{}$it.address$],
$endif$
$if(it.postal-code)$
    postal-code: [#{}$it.postal-code$],
$endif$
$if(it.city)$
    city: [#{}$it.city$],
$endif$
$if(it.country)$
    country: [#{}$it.country$],
$endif$
$endfor$
  ),
$endfor$
$if(backaddress)$
  backaddress: [#{}$backaddress$],
$endif$
$if(letterhead_logo)$
  logo: [#{}$letterhead_logo$],
$endif$
$if(letterhead_logo_width)$
  logo-width: $letterhead_logo_width$,
$endif$
$if(letterhead_background)$
  background: [#{}$letterhead_background$],
$endif$
$if(address)$
  recipient: ($for(address)$[#{}$address$],$endfor$),
$endif$
$if(date)$
  date: [#{}$date$],
$endif$
$if(date_label)$
  date-label: [#{}$date_label$],
$endif$
$if(place)$
  location: [#{}$place$],
$endif$
$if(place_label)$
  location-label: [#{}$place_label$],
$endif$
  references: (
$if(yourref)$
    (key: "yourref", label: $if(yourref_label)$[#{}$yourref_label$]$else$none$endif$, value: [#{}$yourref$]),
$endif$
$if(yourmail)$
    (key: "yourmail", label: $if(yourmail_label)$[#{}$yourmail_label$]$else$none$endif$, value: [#{}$yourmail$]),
$endif$
$if(myref)$
    (key: "myref", label: $if(myref_label)$[#{}$myref_label$]$else$none$endif$, value: [#{}$myref$]),
$endif$
$if(customer)$
    (key: "customer", label: $if(customer_label)$[#{}$customer_label$]$else$none$endif$, value: [#{}$customer$]),
$endif$
$if(invoice)$
    (key: "invoice", label: $if(invoice_label)$[#{}$invoice_label$]$else$none$endif$, value: [#{}$invoice$]),
$endif$
  ),
$if(subject)$
  subject: [#{}$subject$],
$endif$
$if(opening)$
  opening: [#{}$opening$],
$endif$
$if(closing)$
  closing: [#{}$closing$],
$endif$
$if(signature)$
  signature: [#{}$signature$],
$endif$
$if(ps)$
  ps: [#{}$ps$],
$endif$
$if(encl)$
  encl: ($for(encl)$[#{}$encl$],$endfor$),
$endif$
$if(cc)$
  cc: ($for(cc)$[#{}$cc$],$endfor$),
$endif$
$if(footer_columns)$
  footer-columns: ($for(footer_columns)$($for(footer_columns)$[#{}$footer_columns$],$endfor$),$endfor$),
$endif$
  doc,
)
