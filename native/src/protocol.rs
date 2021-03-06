use bincode;

// pub const IN              : u8 = 1;
// pub const CUBE_REQUEST    : u8 = 2;
// pub const CUBE_RESPONSE   : u8 = 3;
// pub const CAMERA          : u8 = 4;
// pub const CAMERA_UNIQ     : u8 = 5;
pub const USER_LOG_IN           : u8 = 6;
pub const USER_LOG_IN_OK        : u8 = 7;
pub const USER_LOG_IN_FAILURE   : u8 = 8;

pub struct UserLogIn {
  i: u8,
  pub name: String
}

pub fn build_user_log_in(bytes: &[u8]) -> UserLogIn {
    let mut string_bytes = bytes[1..].to_vec();
    string_bytes.retain( |&x| x != 0 );
    UserLogIn {
        i: USER_LOG_IN,
        name: String::from_utf8(string_bytes).unwrap()
    }
}

#[derive(Serialize)]
pub struct UserLogInOK {
    i: u8
}

impl UserLogInOK {
    pub fn build() -> UserLogInOK {
        UserLogInOK { i: USER_LOG_IN_OK }
    }

    pub fn serialize(&self) -> Vec<u8> {
        bincode::serialize(self, bincode::Infinite).unwrap()
    }
}

#[derive(Serialize)]
pub struct UserLogInFailure {
    i: u8
}

impl UserLogInFailure {
    pub fn build() -> UserLogInFailure {
        UserLogInFailure { i: USER_LOG_IN_FAILURE }
    }

    pub fn serialize(&self) -> Vec<u8> {
        bincode::serialize(self, bincode::Infinite).unwrap()
    }
}

#[test]
fn test_packets() {
    let pck = UserLogInOK::build();
    assert_eq!(USER_LOG_IN_OK, pck.i);

    let pck = UserLogInFailure::build();
    assert_eq!(USER_LOG_IN_FAILURE, pck.i);
}
