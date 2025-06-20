-- Stores information about individuals who receive donations or participate in campaigns.
CREATE TABLE
    "Recipient" (
        -- Unique identifier for each recipient.
        "id" UUID PRIMARY KEY,
        -- Recipient's first name.
        "firstName" VARCHAR(50) NOT NULL,
        -- Recipient's middle name (father's name).
        "middleName" VARCHAR(50) NOT NULL,
        -- Recipient's last name (grandfather's name).
        "lastName" VARCHAR(50) NOT NULL,
        -- Recipient's date of birth.
        "dateOfBirth" DATE NOT NULL,
        /* Added a unique constraint on the recipient's email. */
        -- Recipient's email address. This is not required.
        "email" VARCHAR(100) NULL UNIQUE,
        /* FIXME(bitbender-8): Made phone nullable for mvp. Will have to get it from auth0, after customizing the signup page. */
        -- Recipient's phone number.
        "phoneNo" VARCHAR(20) NULL UNIQUE,
        /* DOC-UPDATE: Removed columns: loginAttempts, accountLockDate, passwordHash; Added column auth0UserId */
        -- The auth0 user id
        "auth0UserId" VARCHAR(255) NOT NULL UNIQUE,
        -- A short biography or description of the recipient.
        "bio" TEXT,
        -- URL to the recipient's profile picture.
        "profilePictureUrl" TEXT
    );

-- Links recipients to their social media accounts.
CREATE TABLE
    "RecipientSocialMediaHandle" (
        /* DOC-UPDATE: Rename 'handleId' in relational schema to id. */
        "id" UUID PRIMARY KEY,
        -- Unique identifier for each social media handle.
        "recipientId" UUID NOT NULL,
        -- The social media handle url.
        "socialMediaHandle" TEXT NOT NULL,
        -- Foreign key referencing the Recipient table.
        FOREIGN KEY ("recipientId") REFERENCES "Recipient" ("id") ON DELETE CASCADE ON UPDATE CASCADE
    );

-- Stores information about supervisors.
CREATE TABLE
    "Supervisor" (
        -- Unique identifier for each supervisor.
        "id" UUID PRIMARY KEY,
        /* DOC-UPDATE: Removed columns: loginAttempts, accountLockDate, passwordHash; Added column auth0UserId */
        -- The auth0 user id
        "auth0UserId" VARCHAR(255) NOT NULL UNIQUE,
        -- Supervisor's first name.
        "firstName" VARCHAR(50) NOT NULL,
        -- Supervisor's middle name (father's name).
        "middleName" VARCHAR(50) NOT NULL,
        -- Supervisor's last name (grandfather's name).
        "lastName" VARCHAR(50) NOT NULL,
        -- Supervisor's date of birth.
        "dateOfBirth" DATE NOT NULL,
        -- Supervisor's email address.
        "email" VARCHAR(100) NOT NULL UNIQUE,
        -- Supervisor's phone number.
        "phoneNo" VARCHAR(20) NOT NULL UNIQUE
    );

-- Stores notifications sent to recipients or supervisors.
CREATE TABLE
    "Notification" (
        -- Unique identifier for each notification.
        "id" UUID PRIMARY KEY,
        -- Subject/header of the notification.
        "subject" VARCHAR(255) NOT NULL,
        -- Content of the notification.
        "body" TEXT,
        -- Indicates whether the notification has been read.
        "isRead" BOOLEAN NOT NULL,
        /* DOC-UPDATE Changed timestamp column to createdAt bc it causes errors when used in prepared statements (it might be reserved). */
        -- Timestamp when the notification was issued with time zone.
        "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        -- Foreign key referencing the Recipient table.
        "recipientId" UUID REFERENCES "Recipient" ("id") ON UPDATE CASCADE ON DELETE CASCADE,
        -- Foreign key referencing the Supervisor table.
        "supervisorId" UUID REFERENCES "Supervisor" ("id") ON UPDATE CASCADE ON DELETE CASCADE,
        -- A notification can belong either to a recipient or a supervisor. (i.e. recipientId or supervisorId must be set, but not both).
        CHECK (
            (
                "recipientId" IS NOT NULL
                AND "supervisorId" IS NULL
            )
            OR (
                "recipientId" IS NULL
                AND "supervisorId" IS NOT NULL
            )
        )
    );

-- Encapsulates the possible statuses of a campaign.
CREATE TYPE "CampaignStatus" AS ENUM(
    'Pending Review',
    'Verified',
    'Denied',
    'Live',
    'Paused',
    'Completed'
);

-- Stores information about campaigns.
CREATE TABLE
    "Campaign" (
        -- Unique identifier for each campaign.
        "id" UUID PRIMARY KEY,
        -- Title of the campaign.
        "title" VARCHAR(100) NOT NULL,
        -- Description of the campaign.
        "description" VARCHAR(500) NOT NULL,
        -- Fundraising goal for the campaign.
        "fundraisingGoal" BIGINT NOT NULL,
        -- Current status of the campaign.
        "status" "CampaignStatus" NOT NULL,
        -- Category of the campaign.
        "category" VARCHAR(100) NOT NULL,
        -- Bank's code from chapa API.
        "chapaBankCode" INT NULL,
        -- Bank name (if applicable).
        "chapaBankName" VARCHAR(50) NULL,
        -- Bank account number (if applicable).
        "bankAccountNo" VARCHAR(16) NULL,
        -- Timestamp when the campaign was submitted with time zone.
        "submissionDate" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        -- Timestamp when the campaign was verified with time zone.
        "verificationDate" TIMESTAMPTZ NULL,
        -- Timestamp when the campaign was denied with time zone.
        "denialDate" TIMESTAMPTZ NULL,
        -- Timestamp when the campaign was launched with time zone.
        "launchDate" TIMESTAMPTZ NULL,
        -- End date of the campaign with time zone.
        "endDate" TIMESTAMPTZ NULL,
        /* DOC-UPDATE Determines whether the campaign is publicly available. Removes the need to rely on launchDate implicitly. */
        "isPublic" BOOLEAN NOT NULL DEFAULT FALSE,
        -- Foreign key referencing the Recipient table (campaign owner).
        "ownerRecipientId" UUID NOT NULL REFERENCES "Recipient" ("id") ON UPDATE CASCADE ON DELETE CASCADE
        /* DOC-UPDATE: Remove managing supervisor id. All recipients are managed by a single supervisor for now. */
        -- Foreign key referencing the Supervisor table (managing supervisor).
        -- "managingSupervisorId" UUID NOT NULL REFERENCES "Supervisor" ("id")
    );

-- Stores URLs of original campaign documents.
CREATE TABLE
    "CampaignDocuments" (
        /* DOC-UPDATE Changed the name of the column 'documentUrl' to 'url' */
        -- URL of the document.
        "documentUrl" TEXT PRIMARY KEY,
        /* DOC-UPDATE Removed the table 'RedactedCampaignDocuments' in favor of this column. */
        -- URL of the redacted document.
        "redactedDocumentUrl" TEXT NULL,
        -- Foreign key referencing the Campaign table.
        "campaignId" UUID NOT NULL REFERENCES "Campaign" ("id") ON UPDATE CASCADE ON DELETE CASCADE
    );

-- Records a campaign's donation transactions.
CREATE TABLE
    "CampaignDonation" (
        -- Unique identifier for each donation.
        "id" UUID PRIMARY KEY,
        -- Total amount of the donation.
        "grossAmount" BIGINT NOT NULL,
        -- Fee charged for the donation service.
        "serviceFee" BIGINT NOT NULL,
        /* DOC-UPDATE Changed timestamp column to createdAt bc it causes errors when used in prepared statements (it might be reserved). */
        -- Timestamp of the donation transaction with time zone.
        "createdAt" TIMESTAMPTZ NOT NULL,
        -- Transaction reference number returned from the pqyment provider.
        "transactionRef" VARCHAR(255) NOT NULL UNIQUE,
        /* DOC-UPDATE: This is a new property. */
        -- Has the donation amount specified here been transferred to the campaign's account
        "isTransferred" BOOLEAN NOT NULL DEFAULT FALSE,
        -- Foreign key referencing the Campaign table.
        "campaignId" UUID NOT NULL REFERENCES "Campaign" ("id") ON UPDATE CASCADE ON DELETE RESTRICT
    );

-- Stores posts related to a campaign.
CREATE TABLE
    "CampaignPost" (
        -- Unique identifier for each campaign post.
        "id" UUID PRIMARY KEY,
        -- Title of the post.
        "title" VARCHAR(100) NOT NULL,
        -- Content of the post.
        "content" TEXT NOT NULL,
        -- Timestamp when the post became AVAILABLE TO THE PUBLIC. If this attribute is null, then the post is not available to the public. 
        "publicPostDate" TIMESTAMPTZ,
        -- Foreign key referencing the Campaign table.
        "campaignId" UUID NOT NULL REFERENCES "Campaign" ("id") ON UPDATE CASCADE ON DELETE CASCADE
    );

/** 
TODO: (bitbender-8): Propagate to data models in code.
DOC-UPDATE: Update Relational schema and class diagrams.
 */
CREATE TYPE "ResolutionType" AS ENUM('Accepted', 'Rejected');

-- Stores requests to update a campaign post.
CREATE TABLE
    "PostUpdateRequest" (
        -- Unique identifier for each post update request.
        "id" UUID PRIMARY KEY,
        -- Title of the request.
        "title" VARCHAR(100) NOT NULL,
        -- Timestamp when the request was made with time zone.
        "requestDate" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        -- Justification for the post update.
        "justification" TEXT NOT NULL,
        /* DOC-UPDATE: Changed isResolved in favor of storing the date. Update Relational schema and class diagrams. */
        "resolutionDate" TIMESTAMPTZ NULL DEFAULT NULL,
        -- Specifies whether the campaign request is accepted or rejected.
        "resolutionType" "ResolutionType" NULL DEFAULT NULL,
        -- Foreign key referencing the Campaign table.
        "campaignId" UUID NOT NULL REFERENCES "Campaign" ("id") ON UPDATE CASCADE ON DELETE CASCADE,
        -- Foreign key referencing the CampaignPost table.
        "newPostId" UUID NOT NULL UNIQUE REFERENCES "CampaignPost" ("id") ON UPDATE CASCADE ON DELETE CASCADE
    );

-- Stores requests to extend the end date of a campaign.
CREATE TABLE
    "EndDateExtensionRequest" (
        -- Unique identifier for each extension request.
        "id" UUID PRIMARY KEY,
        -- Title of the request.
        "title" VARCHAR(100) NOT NULL,
        -- Timestamp when the request was made with time zone.
        "requestDate" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        -- Justification for the extension request.
        "justification" TEXT NOT NULL,
        /* DOC-UPDATE: Changed isResolved in favor of storing the date. Update Relational schema and class diagrams. */
        "resolutionDate" TIMESTAMPTZ NULL DEFAULT NULL,
        -- Specifies whether the campaign request is accepted or rejected.
        "resolutionType" "ResolutionType" NULL DEFAULT NULL,
        -- The new proposed end date with time zone.
        "newEndDate" TIMESTAMPTZ NOT NULL,
        -- Foreign key referencing the Campaign table.
        "campaignId" UUID NOT NULL REFERENCES "Campaign" ("id") ON UPDATE CASCADE ON DELETE CASCADE
    );

-- Stores requests to adjust the fundraising goal of a campaign.
CREATE TABLE
    "GoalAdjustmentRequest" (
        -- Unique identifier for each goal adjustment request.
        "id" UUID PRIMARY KEY,
        -- Title of the request.
        "title" VARCHAR(100) NOT NULL,
        -- Timestamp when the request was made with time zone.
        "requestDate" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        -- Justification for the goal adjustment.
        "justification" TEXT NOT NULL,
        /* DOC-UPDATE: Changed isResolved in favor of storing the date. Update Relational schema and class diagrams. */
        "resolutionDate" TIMESTAMPTZ NULL DEFAULT NULL,
        -- Specifies whether the campaign request is accepted or rejected.
        "resolutionType" "ResolutionType" NULL DEFAULT NULL,
        -- The new proposed fundraising goal.
        "newGoal" BIGINT NOT NULL,
        -- Foreign key referencing the Campaign table.
        "campaignId" UUID NOT NULL REFERENCES "Campaign" ("id") ON UPDATE CASCADE ON DELETE CASCADE
    );

-- Stores requests to change the status of a campaign.
CREATE TABLE
    "StatusChangeRequest" (
        -- Unique identifier for each status change request.
        "id" UUID PRIMARY KEY,
        -- Title of the request.
        "title" VARCHAR(100) NOT NULL,
        -- Timestamp when the request was made with time zone.
        "requestDate" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        -- Justification for the status change.
        "justification" TEXT NOT NULL,
        /* DOC-UPDATE: Changed isResolved in favor of storing the date. Update Relational schema and class diagrams. */
        "resolutionDate" TIMESTAMPTZ NULL DEFAULT NULL,
        -- Specifies whether the campaign request is accepted or rejected.
        "resolutionType" "ResolutionType" NULL DEFAULT NULL,
        -- The new proposed status.
        "newStatus" "CampaignStatus" NOT NULL,
        -- Foreign key referencing the Campaign table.
        "campaignId" UUID NOT NULL REFERENCES "Campaign" ("id") ON UPDATE CASCADE ON DELETE CASCADE
    );