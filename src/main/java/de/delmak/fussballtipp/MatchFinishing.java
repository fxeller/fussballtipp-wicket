package de.delmak.fussballtipp;

import de.delmak.fussballtipp.persistence.Match;
import de.delmak.fussballtipp.persistence.Team;
import org.apache.wicket.authroles.authorization.strategies.role.annotations.AuthorizeInstantiation;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.form.Form;
import org.apache.wicket.markup.html.form.TextField;
import org.apache.wicket.markup.html.link.BookmarkablePageLink;
import org.apache.wicket.markup.html.panel.FeedbackPanel;
import org.apache.wicket.model.PropertyModel;
import org.apache.wicket.request.mapper.parameter.PageParameters;
import org.apache.wicket.util.string.StringValue;
import org.apache.wicket.validation.validator.RangeValidator;

@AuthorizeInstantiation({"ADMIN","TIPPADMIN"})
public class MatchFinishing extends BasePage
{

	private Match match;

	public final Match getMatch()
	{
		return match;
	}

	public final void setMatch(Match match)
	{
		this.match = match;
	}

	private Integer phaseId;

	public final Integer getPhaseId()
	{
		return phaseId;
	}

	public final void setPhaseId(Integer phaseId)
	{
		this.phaseId = phaseId;
	}

	private PageParameters pageParamsBackToMaster = new PageParameters();

	public final PageParameters getPageParamsBackToMaster()
	{
		return pageParamsBackToMaster;
	}

	public final void setPageParamsBackToMaster(PageParameters pageParamsBackToMaster)
	{
		this.pageParamsBackToMaster = pageParamsBackToMaster;
	}

	public MatchFinishing(final PageParameters parameters)
	{
		StringValue paramMatchId = parameters.get("matchid");
		if (paramMatchId.isEmpty() == false)
		{
			setMatch(Match.getById(paramMatchId.toInt()));
		}

		StringValue paramPhaseId = parameters.get("phaseid");
		if (paramPhaseId.isEmpty() == false)
		{
			setPhaseId(paramPhaseId.toInt());
		}
		
		getPageParamsBackToMaster().add("viewmode", BetView.BETVIEWMODE_MATCH);

		if (getPhaseId() != null)
		{
			getPageParamsBackToMaster().add("phaseid", getPhaseId());
		}

		add(new BookmarkablePageLink("lnkBackToMaster", BetView.class, getPageParamsBackToMaster()));
		
		Form frmMatchFinishing = new Form("frmMatchFinishing")
		{
			
			@Override
			protected void onSubmit()
			{
				Match.modify(getMatch());
				
				setResponsePage(BetView.class, getPageParamsBackToMaster());
			}
			
		};
		
		add(frmMatchFinishing);

		Team teamHome = null;
		Team teamGuest = null;
		
		if (getMatch() != null)
		{
			teamHome = getMatch().getTeamHome();
			teamGuest = getMatch().getTeamGuest();
		}
		
		frmMatchFinishing.add(new Label("lblTeamHome", new PropertyModel(teamHome, "description")));
		
		TextField txtScoreHome = new TextField("txtScoreHome", new PropertyModel(getMatch(), "scoreHome"));
		txtScoreHome.setRequired(true);
		txtScoreHome.add(new RangeValidator(0, 99));
		frmMatchFinishing.add(txtScoreHome);
		
		frmMatchFinishing.add(new Label("lblTeamGuest", new PropertyModel(teamGuest, "description")));
		
		TextField txtScoreGuest = new TextField("txtScoreGuest", new PropertyModel(getMatch(), "scoreGuest"));
		txtScoreGuest.setRequired(true);
		txtScoreGuest.add(new RangeValidator(0, 99));
		frmMatchFinishing.add(txtScoreGuest);
		
		FeedbackPanel pnlFeedback = new FeedbackPanel("pnlFeedback");
		add(pnlFeedback);
	}
}
