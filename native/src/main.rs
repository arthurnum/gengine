extern crate bincode;
extern crate serde;

#[macro_use]
extern crate serde_derive;

use std::net::{UdpSocket, SocketAddr};
use std::collections::HashMap;

#[derive(Deserialize)]
struct CamPos {
  _i: u8,
  x: f64,
  y: f64,
  z: f64
}

#[derive(Serialize)]
struct CamPosUniq {
  i: u8,
  id: Vec<u8>,
  x: f64,
  y: f64,
  z: f64
}

impl CamPos {
  fn to_uniq(&self, id_str: String) -> CamPosUniq {
    let mut borrow_id_bytes = id_str.into_bytes();
    let id_bytes: Vec<u8> = borrow_id_bytes.drain(8..).collect();

    CamPosUniq {
      i: 5,
      id: id_bytes,
      x: self.x,
      y: self.y,
      z: self.z
    }
  }
}

fn sleep_nop() {
  std::thread::sleep(std::time::Duration::from_millis(100));
}

fn id_format(src_addr: &SocketAddr) -> String {
  let id_str = format!("{}_{}", src_addr.ip(), src_addr.port());
  format!("{:>24}", id_str)
}

fn main() {
  let socket = UdpSocket::bind("127.0.0.1:45000").expect("couldn't bind to address");
  socket.set_nonblocking(true).expect("couldn't set nonblocking");

  let mut cameras_hash: HashMap<String, CamPosUniq> = HashMap::new();
  let mut buf: [u8; 128] = [0; 128];
  let separator = "PCK".to_string().into_bytes();

  loop {
    let recr = socket.recv_from(&mut buf);

    if recr.is_ok() {
      let (_, src_addr) = recr.expect("coundn't read a package");
      let id_str = id_format(&src_addr);
      let f1: CamPos = bincode::deserialize(&buf).unwrap();

      cameras_hash.insert(id_str.clone(), f1.to_uniq(id_str));

      let mut complete_package: Vec<u8> = Vec::new();
      for (_k, v) in &cameras_hash {
        complete_package.extend(bincode::serialize(&v, bincode::Infinite).unwrap().iter());
        complete_package.extend(separator.iter().clone());
      }

      socket.send_to(&complete_package, src_addr).expect("couldn't send a package");

    } else { sleep_nop(); }
  }
}
