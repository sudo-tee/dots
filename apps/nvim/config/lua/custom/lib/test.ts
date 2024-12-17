const hello = (t) => `hello ${t}`;
const hello2 = (t) => `hello ${t}`;
const ee = () => "ee";

function gg(t) {
  return `hello ${t}`;
}

function* allo(t, _ff) {
  const allo = "allo";
  console.log(t, allo);
  yield allo;
}

function ee() {}

const logthis = (function (t, _ff) {
  const allo = "allo";
  return console.log(t, allo);
})(
  (function (t, _ff) {
    const allo = "allo";
    return console.log(t, allo);
  })(),
);

function l(t, _ff) {}

function rethis(t, ff) {
  return t + ff;
}

[].forEach((t) => console.log(t));
[].forEach(function (t) {
  console.log(t);
});

const c = {
  cc: () => console.log("cc"),
  bb: function () {
    console.log("bb");
  },
};

const patate = () => console.log("patate");

const sort = (a, b) => a > b;

class Test {
  c = () => "c";
  hello() {
    return "hello";
  }

  world() {
    return "world";
  }

  public static hi = (name): string => {
    const hi = "hi ";
    return hi + name;
  };
}

console.log(((bar) => "baz")());
