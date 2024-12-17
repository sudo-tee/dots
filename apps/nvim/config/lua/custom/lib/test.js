const hello = (t) => `hello ${t}`;
const hello2 = (t) => `hello ${t}`;
const ee = () => "ee";

function gg(t) {
  return `hello ${t}`;
}

function logthis(t, _ff) {
  const allo = "allo";
  console.log(t, allo);
}

function ee() {}

function logthis(t, _ff) {
  const allo = "allo";
  return console.log(t, allo);
}

const log_ret_this = (t, _ff) => {
  const allo = "allo";
  return console.log(t, allo);
};

const rethis = (t, ff) => t + ff;

const c = {
  cc: () => console.log("cc"),
};

const patate = () => console.log("patate");

const sort = (a, b) => a > b;

class Test {
  hello() {
    return "hello";
  }

  world = () => "world";

  hi(name) {
    const hi = "hi ";
    return hi + name;
  }
}

console.log(((bar) => "baz")());
