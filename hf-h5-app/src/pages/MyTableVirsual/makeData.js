import { faker } from "@faker-js/faker";
const range = (len) => {
  const arr = [];
  for (let i = 0; i < len; i++) {
    arr.push(i);
  }
  return arr;
};

const newPerson = (index) => {
  return {
    id: index + 1,
    firstName: faker.person.firstName(),
    lastName: faker.person.lastName(),
    age: faker.number.int(40),
    visits: faker.number.int(1000),
    progress: faker.number.int(100),
    createdAt: faker.date.anytime(),
    status: faker.helpers.shuffle(["relationship", "complicated", "single"])[0],
  };
};

export function makeData(...lens) {
  const makeDataLevel = (depth = 0) => {
    const len = lens[depth];
    return range(len).map((d) => {
      return {
        ...newPerson(d),
      };
    });
  };

  return makeDataLevel();
}

const data = makeData(50);

//simulates a backend api
export const fetchData = async (start, size, sorting) => {
  const dbData = [...data];
  if (sorting.length) {
    const sort = sorting[0];
    const { id, desc } = sort;
    dbData.sort((a, b) => {
      if (desc) {
        return a[id] < b[id] ? 1 : -1;
      }
      return a[id] > b[id] ? 1 : -1;
    });
  }

  //simulate a backend api
  await new Promise((resolve) => {
    setTimeout(() => {
      resolve?.();
    }, 200);
  });

  return {
    data: dbData.slice(start, start + size),
    meta: {
      totalRowCount: dbData.length,
    },
  };
};
