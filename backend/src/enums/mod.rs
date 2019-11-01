use juniper::GraphQLEnum;

#[derive(GraphQLEnum, Debug, PartialEq, DbEnum, Clone)]
#[DieselType = "Publication_model"]
pub enum PublicationModel {
    Subscription, //Closed, not OA
    BronzeOpenAccess, //Delayed OA, Closed for a period of time, then released as OA in some form
    HybridOpenAccess, //'Open Choice' puts burden on authors to pay for open access, otherwise closed
    GreenOpenAccess, //Allows self-archiving of authors work outside of the journals garden
    GoldOpenAccess, //All content open for free and immediately for viewing. Usually under CC.
    PlatinumOpenAcess, //Same as Gold, but do not charge the authors an APC.
}

#[derive(GraphQLEnum, Debug, PartialEq, DbEnum, Clone)]
#[DieselType = "Fee_category"]
pub enum FeeCategory {
    ArticleProcessingCharge, //Explicitly for OA.
    Publication, //Charges for pulication, generally in closed models.
    Subscription, //Yearly fee for access to articles.
    PayPerView, //Cost to read single article.
}

#[derive(GraphQLEnum, Debug, PartialEq, DbEnum, Clone)]
#[DieselType = "Maybe_logic"]
pub enum MaybeLogic {
    Yes,
    No,
    Unkown,
    NotNeeded,
}


