// Owner: Lead. Shared sidebar, role check and assistant chat for every page.
const role=sessionStorage.getItem('role');if(!role)location.replace('login.html');
const nav=[['dashboard','Dashboard','manager'],['floor','Tables & reservations','manager waiter'],['menu','Menu','manager waiter chef customer'],['order','New order','manager waiter'],['kitchen','Kitchen','manager chef'],['billing','Billing','manager waiter'],['inventory','Inventory','manager chef'],['staff','Staff & shifts','manager'],['reports','Reports','manager'],['myres','My reservations','customer'],['mypay','My bills & payment','customer']];
const home={manager:'dashboard',waiter:'floor',chef:'kitchen',customer:'myres'};
const names={manager:'Ayesha, Manager',waiter:'Bilal, Waiter',chef:'Imran, Chef',customer:'Hamza, Customer'};
const can=r=>r.split(' ').includes(role),page=location.pathname.split('/').pop().replace('.html','');
const cur=nav.find(n=>n[0]===page);if(cur&&!can(cur[2]))location.replace(home[role]+'.html');
const links=nav.filter(n=>can(n[2])).map(n=>`<a href="${n[0]}.html"${n[0]===page?' class="on"':''}>${n[1].replace('&','&amp;')}</a>`).join('');
document.body.insertAdjacentHTML('afterbegin',`<aside><h1>Restaurant Manager</h1><nav>${links}</nav><p class="who">Signed in as<br><b>${names[role]}</b><br><a href="login.html" id="out">Sign out</a></p></aside>`);
document.getElementById('out').onclick=()=>sessionStorage.removeItem('role');
document.body.insertAdjacentHTML('beforeend',`<button id="chatBtn">Ask assistant</button><div id="chat" role="dialog" aria-label="Assistant"><header>Restaurant assistant</header><div id="msgs"><div class="m bot">Hi! Ask me how to take an order, split a bill or restock an item.</div></div><form id="chatForm"><input name="q" placeholder="Type your question" aria-label="Your question"><button>Send</button></form></div>`);
const chat=document.getElementById('chat'),msgs=document.getElementById('msgs');
document.getElementById('chatBtn').onclick=()=>chat.classList.toggle('on');
document.getElementById('chatForm').onsubmit=e=>{e.preventDefault();const i=e.target.q,t=i.value.trim();if(!t)return;
add(t,'me');i.value='';setTimeout(()=>add('The assistant is not connected yet. Once the Gemini backend is added, answers will appear here.','bot'),400);};
function add(t,c){const d=document.createElement('div');d.className='m '+c;d.textContent=t;msgs.appendChild(d);msgs.scrollTop=msgs.scrollHeight;}