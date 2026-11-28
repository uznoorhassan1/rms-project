const chat=document.getElementById('chat'),msgs=document.getElementById('msgs');
document.getElementById('chatBtn').onclick=()=>chat.classList.toggle('on');
const csrf=()=>(document.cookie.split('; ').find(c=>c.startsWith('csrftoken='))||'').split('=')[1];
function add(t,c){const d=document.createElement('div');d.className='m '+c;d.textContent=t;msgs.appendChild(d);msgs.scrollTop=msgs.scrollHeight;}
document.getElementById('chatForm').onsubmit=async e=>{e.preventDefault();const i=e.target.q,t=i.value.trim();if(!t)return;add(t,'me');i.value='';
try{const r=await fetch('/assistant/',{method:'POST',headers:{'Content-Type':'application/json','X-CSRFToken':csrf()},body:JSON.stringify({q:t})});add((await r.json()).answer,'bot');}
catch(x){add('Could not reach the assistant.','bot');}};
