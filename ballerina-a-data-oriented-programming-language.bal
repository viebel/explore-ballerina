import ballerina/io;
type Author record {
    string firstName;
    string lastName;
};

type Book record {
    string title;
    Author author;
};

type Member record {
    string firstName;
    string lastName;
    int age;
    Book[] books?; // books is an optional field
};

function fullName(record {
                      string firstName;
                      string lastName;
                  } a)
                returns string {
    return a.firstName + " " + a.lastName;
}

function enrichAuthor(Author author) returns Author {
   author["fullName"] = fullName(author);
   return author;
}

function enrichBooks(Book[] books) returns Book[] {
    return from var {author, title} in books
        where title.includes("Volleyball") // filter books whose title include Volleyball
        let Author enrichedAuthor = enrichAuthor(author) // enrich the author field
        select {author: enrichedAuthor, title: title}; // select some fields 
}

function enrichMember(Member member) returns Member {
    member["fullName"] = fullName(member); // fullName works on member and authors
    Book[]? books = member.books; // books is an optional field,
    if (books is ()) { // handle explicitly the case where the field is not present
        return member;
    }
    // the type system is smart enough to understand that here books is guaranteed to be an array
    member.books = enrichBooks(books);
    return member;
}

function entryPoint(string memberJSON) returns string|error {
    Member member = check memberJSON.fromJsonStringWithType();
    var enrichedMember = enrichMember(member);
    return enrichedMember.toJsonString();
}

public function main() {
    var kelly = "{\"firstName\":\"Kelly\",\"lastName\":\"Kapowski\",\"age\":17,\"books\":[{\"title\":\"The Volleyball Handbook\",\"author\":{\"firstName\":\"Bob\",\"lastName\":\"Miller\",\"fullName\":\"Bob Miller\"}}]}";
    io:println(entryPoint(kelly));
}

