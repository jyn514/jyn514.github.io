use std::collections::btree_map::Entry;
use{String as Str,Some as S,None as N,println as pr,unimplemented as die,matches as m,Iterator as I};
use{Option as O,std::{fs,fs::File as F,collections::BTreeMap,io::Write,iter::Peekable as Pk}};
use pulldown_cmark::{Event as E,Options as PO,Parser as P,Tag as T,TagEnd as TE,LinkType as K};
use scraper::{Html as H,Selector as Sel,ElementRef as El};
type R<O=()>=anyhow::Result<O>;type M=BTreeMap<Str,Str>;const L:&str="links.bin";const B:&str="bibliography";
fn load()->R<M>{Ok(fs::read_to_string(L)?.lines().flat_map(|l|{
	let(k,v)=l.split_once('\0')?;S((k.into(),v.into()))
}).collect())}
fn save(m:&M)->R{let mut fd=F::create(L)?;for(k,v)in m{
	fd.write_all(k.as_bytes())?;fd.write_all(b"\0")?;fd.write_all(v.as_bytes())?;fd.write_all(b"\n")?;
}fd.flush().map_err(Into::into)}
fn main()->R{let mut m=load().unwrap_or_default();let ps=std::env::args().skip(1).map(|a|
	R::Ok(post(&std::fs::read_to_string(&a)?,&mut m)?)
).collect::<R<Vec<_>>>()?;save(&m)?;for p in ps{
	pr!("---\n## {B}\n");for l in p{pr!("- [{}]({l})",m.get(&l).map(|s|&**s).unwrap_or(""))}
}Ok(())}
fn bib(e:O<&E>)->bool{m!(e,S(E::Text(t))if t.eq_ignore_ascii_case(B))}
fn name<'a>(t:&mut Str,id:&str,k:K,p:&mut Pk<impl I<Item=E<'a>>>){
	if k==K::Inline{for e in p.by_ref().take_while(|e|!m!(e,E::End(TE::Link{..}))){
		match e{E::Text(nt)=>*t+=&nt,E::Code(nt)=>*t+=&nt,
			E::SoftBreak|E::Start(..)|E::End(..)=>{},o=>{die!("{o:?}: {t} {id}")}
	}}}if t.is_empty(){*t+=id}}
fn post(src:&str,m:&mut M)->R<Vec<Str>>{let mut p=P::new_ext(src,PO::all()).peekable();
	let mut b=false;let mut v=vec![];while let S(e)=p.next(){
		if m!(e,E::Start(T::Heading{..})){b=bib(p.peek())}else if m!(e,E::Start(T::FootnoteDefinition(..))){b=false}
		let E::Start(T::Link{link_type:ty,dest_url:d,title:t,id})=e else{continue};
		if!d.starts_with("http"){continue;}
		let mut t=t.into();let k=d.split_once('#').map_or(d.to_string(),|t|t.0.to_string());name(&mut t,&id,ty,&mut p);
		if b{m.insert(k,t);}else{
			if!d.split('#').next().unwrap().ends_with(".pdf"){if let Entry::Vacant(h)=m.entry(k.clone()){
				if let S(c)=infer(&d){h.insert(c);}}}
			v.push(k);}}Ok(v)}
fn infer(u:&str)->O<Str>{let h=H::parse_document(&fetch(u).inspect_err(|e|{dbg!(e);}).ok()?);
	match(sel("meta[name=author]",&h).and_then(|n|n.attr("content")),sel("title",&h).map(|n|n.text().collect::<String>())){
		(S(a),S(t))=>S(format!("{a}, “{t}”")),
		(S(a),N   )=>S(format!("{a}")),
		(N   ,S(t))=>S(format!("“{t}”")),
		(N   ,N   )=>N}}
fn fetch(u:&str)->R<Str>{Ok(ureq::get(dbg!(u)).call()?.body_mut().read_to_string()?)}
fn sel<'h>(s:&str,h:&'h H)->O<El<'h>>{h.select(&Sel::parse(s).unwrap()).next()}
