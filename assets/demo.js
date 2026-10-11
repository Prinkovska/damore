/* D'AMORE · демо-режим портфоліо-версії: кошик і оплата вимкнені, замість них – підказка.
   Працюють посилання #order, #demo-cart, #demo і кнопки з класом js-store-prod-btn. */
(function(){
  'use strict';
  var st = document.createElement('style');
  st.textContent =
    '.dm-toast{position:fixed; left:50%; bottom:28px; z-index:1000001; max-width:min(92vw,460px); padding:15px 22px; border-radius:99px; transform:translate(-50%,24px); opacity:0; pointer-events:none;' +
    'font:400 15px/1.35 "Onest","Helvetica Neue",Arial,sans-serif; letter-spacing:.01em; text-align:center; color:#FFF4EC; background:#3a2c26; box-shadow:0 18px 40px -14px rgba(0,0,0,.5);' +
    'transition:opacity .35s ease, transform .5s cubic-bezier(.2,.8,.2,1)}' +
    '.dm-toast.on{opacity:1; transform:translate(-50%,0)}' +
    '.dm-toast b{font-weight:500; color:#E0705F}';
  document.head.appendChild(st);

  var el = document.createElement('div');
  el.className = 'dm-toast'; el.setAttribute('role', 'status'); el.setAttribute('aria-live', 'polite');
  var tm = 0;
  function toast(html){
    if (!el.parentNode) document.body.appendChild(el);
    el.innerHTML = html; void el.offsetWidth; el.classList.add('on');
    clearTimeout(tm); tm = setTimeout(function(){ el.classList.remove('on'); }, 3600);
  }

  function count(){
    try { var o = JSON.parse(window.localStorage.getItem('tcart') || '{}'); return (o.products && o.products[0] && parseInt(o.products[0].quantity, 10)) || 0; } catch(e){ return 0; }
  }
  function setCount(n){
    try { window.localStorage.setItem('tcart', JSON.stringify({ products: n > 0 ? [{ name:'Холодна реконструкція D’AMORE', quantity:n, price:'2000' }] : [] })); } catch(e){}
  }

  document.addEventListener('click', function(e){
    if (e.defaultPrevented) return;                       // кнопку вже обробив інший скрипт (напр. hero натиснув штатну кнопку «Купити»)
    var t = e.target && e.target.closest ? e.target : null;
    if (!t) return;
    var buy = t.closest('.js-store-prod-btn');
    if (buy){
      e.preventDefault();
      var n = count() + 1; setCount(n);
      toast('Додано до кошика (демо). <b>Товарів: ' + n + '</b><br>Це портфоліо-версія: оплата вимкнена.');
      return;
    }
    var a = t.closest('a[href]');
    if (!a) return;
    var h = a.getAttribute('href');
    if (h === '#demo-cart' || h === '#order'){
      e.preventDefault();
      var c = count();
      toast(c ? 'Демо-кошик: <b>' + c + ' товар(и)</b>. Оплата вимкнена.' : 'Кошик порожній. Це демо-версія: оплата вимкнена.');
    } else if (h === '#demo'){
      e.preventDefault();
      toast('Ця сторінка не входить у демо-версію.');
    }
  });
})();
