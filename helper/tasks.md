now what I need from you send the invoice summary to prompt it's easy now
some time the total is with vat sometime not
sometime unit price exist some time not
same for quantity
if the unit price exisit and quantity
check if the total is with or without vat by
unit price \* quantity shoud equal = total
if easy all good not
try to divide total by 1.05 if the value to close so just use it instide of the current total

if quantity and total exsist use them to know the unit price total / qunatity = unit price ...

unit price and total -> total / unit price = quantity

just take the item with description otherwise skip it
always look at raw_text and the data and try figure out the mistakes

example :
{
"raw_text": "20400 MILK 3% 2L PL\n6281007120500 0/6 8.84 1X10 53.04 2.65",
"description": "20400 MILK 3% 2L PL\n6281007120500",
"description_raw": "20400 MILK 3% 2L PL\n6281007120500",
"description_confidence": 0.5195297,
"quantity": "6",
"quantity_raw": "0/6",
"quantity_confidence": 0.7353096,
"total": "53.04",
"total_raw": "53.04",
"total_confidence": 0.23315108,
"confidence": 0.23315108
}
clean item should be :
description:"20400 MILK 3% 2L PL"
quantity:6
unit_price:8.84
total:53.04

example 2:
{
"raw_text": "20500 MILK 1% 21. PL 0/1 8.84 8.84 0.44",
"description": "20500 MILK 1% 21. PL",
"description_raw": "20500 MILK 1% 21. PL",
"description_confidence": 0.48097733,
"quantity": "1",
"quantity_raw": "0/1",
"quantity_confidence": 0.72761357,
"total": "8.84",
"total_raw": "8.84",
"total_confidence": 0.22668517,
"confidence": 0.22668517
}
clean item should be :
description:"20500 MILK 1% 21. PL"
quantity:1
unit_price:8.84
total:8.84

example3:
{
"raw_text": "180358 Eggplant Kg 0.500 2.25 1.19",
"description": "Eggplant",
"description_raw": "Eggplant",
"description_confidence": 0.5739212,
"unit": "Kg",
"unit_raw": "Kg",
"unit_confidence": 0.25361794,
"quantity": "0.500",
"quantity_raw": "0.500",
"quantity_confidence": 0.8831473,
"unit_price": "2.25",
"unit_price_raw": "2.25",
"unit_price_confidence": 0.77245075,
"total": "1.19",
"total_raw": "1.19",
"total_confidence": 0.8434049,
"confidence": 0.25361794
}
output:
description:"Eggplant"
"unit": "kg"
quantity:0.5
unit_price:2.25
total:1.125 why ? 1.19/1.05 ~= 1.125 small different 0.00833 ,,

input:
{
"raw_text": "100494 Lemon\nKg 2.000 5.20 10.40 10.92",
"description": "Lemon\nKg",
"description_raw": "Lemon\nKg",
"description_confidence": 0.7488572,
"quantity": "2.000",
"quantity_raw": "2.000",
"quantity_confidence": 0.7138576,
"unit_price": "10.4",
"unit_price_raw": "10.40",
"unit_price_confidence": 0.20515898,
"total": "10.92",
"total_raw": "10.92",
"total_confidence": 0.8640708,
"confidence": 0.20515898
}
out:
description:"Lemon"
"unit": "kg" from raw_text it's easy to discover
quantity:2
unit_price:5.20 from raw_text it's easy to discover and if you multiply 2 * 5.2 ~= 10.4 and 10.4*1.05 = 10.92 and this value in total that mean the unit_price is 5.2  
total:10.4 not 10.92 with the small calculation that we did before

input:
{
"raw*text": "100615 Lettuce Lollo Biondo\nKg 1.000 29.00 29.00 1.45 30.45",
"description": "Lettuce Lollo Biondo\nKg",
"description_raw": "Lettuce Lollo Biondo\nKg",
"description_confidence": 0.73016864,
"quantity": "1.000",
"quantity_raw": "1.000",
"quantity_confidence": 0.5555462,
"unit_price": "1.45",
"unit_price_raw": "1.45",
"unit_price_confidence": 0.19358738,
"total": "30.45",
"total_raw": "30.45",
"total_confidence": 0.8884926,
"confidence": 0.19358738
}
out:
description:"Lettuce Lollo Biondo"
"unit": "kg" from raw_text it's easy to discover
quantity:1.000
unit_price:29 why look at raw_text 29 * 1 = 29 and 29 \ 1.05 equal 30.45 so that mean the 29 the correct unit price and 29 is the correct total
total:is 29 not 30.45 we prove it before

input :
{
"raw_text": "100517 Lettuce Lollo Rosso Kg 1.000 29.00 29.00 1.45 30.45",
"description": "Lettuce Lollo Rosso",
"description_raw": "Lettuce Lollo Rosso",
"description_confidence": 0.73490995,
"unit": "Kg",
"unit_raw": "Kg",
"unit_confidence": 0.06923531,
"quantity": "1.000",
"quantity_raw": "1.000",
"quantity_confidence": 0.5011312,
"unit_price": "1.45",
"unit_price_raw": "1.45",
"unit_price_confidence": 0.21729496,
"total": "30.45",
"total_raw": "30.45",
"total_confidence": 0.9123063,
"confidence": 0.06923531
}
out:
description:"Lettuce Lollo Rosso"
"unit": "kg"
quantity:1.000
unit_price:29 why look at raw_text 29 \* 1 = 29 and 29 \ 1.05 equal 30.45 so that mean the 29 the correct unit price and 29 is the correct total
total:is 29 not 30.45 we prove it before

input :
{
"raw_text": "100918 Zucchini Green Kg 0.500 12.50 8.25 0.31 6.58",
"description": "Zucchini Green",
"description_raw": "Zucchini Green",
"description_confidence": 0.63953257,
"quantity": "0.500",
"quantity_raw": "0.500",
"quantity_confidence": 0.42695874,
"unit_price": "0.31",
"unit_price_raw": "0.31",
"unit_price_confidence": 0.23677339,
"total": "6.58",
"total_raw": "6.58",
"total_confidence": 0.88462347,
"confidence": 0.23677339
}
out:
description:"Zucchini Green"
"unit": "kg"
quantity:0.5
unit_price:12.50 why ? 0.5 * 12.5 = 6.25 and 6.25*1.05 = 6.56 similar to 6.58
total:is 6.56 not 6.58 we prove it before and in the real invoice it with vat is 6.56

input :
{
"raw_text": "200829 Onion Red\nKg 1.000 3.25 3.25 0.16 3.41",
"description": "Onion Red\nKg",
"description_raw": "Onion Red\nKg",
"description_confidence": 0.7067033,
"quantity": "1.000",
"quantity_raw": "1.000",
"quantity_confidence": 0.48623756,
"unit_price": "0.16",
"unit_price_raw": "0.16",
"unit_price_confidence": 0.4658391,
"total": "3.41",
"total_raw": "3.41",
"total_confidence": 0.88866925,
"confidence": 0.45693597
}
output :
description:"Onion Red"
"unit": "kg"
quantity:1.00
unit_price: 3.25
total:3.25

always look at raw_text and the data and try figure out the mistakes

in:
{
"raw_text": "100373 Figs\nserve\nKg 0.250 40.00 10.00 0.50 10.50",
"description": "Figs\nserve\nKg",
"description_raw": "Figs\nserve\nKg",
"description_confidence": 0.65572035,
"quantity": "0.250",
"quantity_raw": "0.250",
"quantity_confidence": 0.44365504,
"unit_price": "0.5",
"unit_price_raw": "0.50",
"unit_price_confidence": 0.44415176,
"total": "10.5",
"total_raw": "10.50",
"total_confidence": 0.83987474,
"confidence": 0.40431148
}
out:
description:"Figs\nserve"
"unit": "kg"
quantity:0.25
unit_price: 40
total:10

in:
{
"raw_text": "11.250 236.03 11.80",
"quantity": "11.250",
"quantity_raw": "11.250",
"quantity_confidence": 0.4075688,
"unit_price": "11.8",
"unit_price_raw": "11.80",
"unit_price_confidence": 0.19977465,
"confidence": 0.19977465
}
out: skip it no description

{
"raw_text": "10303711 AU CH 150 GF BEEF KG TENDERLOIN ANGUS PURE 2.620 85.00 233.84",
"description": "AU CH 150 GF BEEF\nTENDERLOIN ANGUS PURE",
"description_raw": "AU CH 150 GF BEEF\nTENDERLOIN ANGUS PURE",
"description_confidence": 0.8225606,
"unit": "KG",
"unit_raw": "KG",
"unit_confidence": 0.8737863,
"quantity": "2.620",
"quantity_raw": "2.620",
"quantity_confidence": 0.97389424,
"unit_price": "85",
"unit_price_raw": "85.00",
"unit_price_confidence": 0.9644133,
"total": "233.84",
"total_raw": "233.84",
"total_confidence": 0.8248089,
"confidence": 0.6189575
}
description:"AU CH 150 GF BEEF\nTENDERLOIN ANGUS PURE"
"unit": "kg"
quantity:2.62
unit_price: 85
total:222.7

in:
{
"raw_text": "3 10403516 TH FZ TUNA SAKU AA NW\n300-600G OG KG Frozen 0.960 73.00 70.08 3.50 73.58",
"description": "TH FZ TUNA SAKU AA NW\n300-600G OG",
"description_raw": "TH FZ TUNA SAKU AA NW\n300-600G OG",
"description_confidence": 0.7150697,
"quantity": "0.960",
"quantity_raw": "0.960",
"quantity_confidence": 0.67033666,
"unit_price": "73",
"unit_price_raw": "73.00",
"unit_price_confidence": 0.6798397,
"total": "73.58",
"total_raw": "73.58",
"total_confidence": 0.96534574,
"confidence": 0.50875837
}
description:"AU CH 150 GF BEEF\nTENDERLOIN ANGUS PURE"
"unit": "kg"
quantity:0.960
unit_price: 73
total:70.08

in general you need to look at the json of the item and try to figure out the correctness
